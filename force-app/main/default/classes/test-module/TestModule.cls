@IsTest
@TestVisible
private class TestModule {
    public class TestModuleException extends Exception {}

    private static Integer fakeIdCounter = 1;

    public static Id fakeId(SObjectType sot) {
        String keyPrefix = sot.getDescribe().getKeyPrefix();
        return Id.valueOf(keyPrefix + '0'.repeat(12 - String.valueOf(fakeIdCounter).length()) + fakeIdCounter++);
    }

    public interface BuilderProvider {
        Builder Builder();
    }

    public interface MockerProvider {
        Mocker Mocker();
    }

    public interface Builder {
        Builder set(SObjectField field, Object value);
        Builder set(String field, Object value);
        Builder useTemplate(String templateName);
        Builder useRandomizer(Randomizer randomizer);

        SObject build();
        SObject buildAndInsert();
        List<SObject> build(Integer amount);
        List<SObject> buildAndInsert(Integer amount);
    }

    public interface Mocker {
        Mocker set(SObjectField field, Object value);
        Mocker set(String field, Object value);
        Mocker setChildren(String relationship, List<SObject> children);
        Mocker setFakeId();

        SObject build();
        List<SObject> build(Integer amount);
    }

    public interface Template {
        SObject defaultTemplate();
        Map<String, SObject> templates();
    }

    public interface Randomizer {
        Map<SObjectField, Object> generate(Integer index);
    }

    public abstract class RecordBuilder implements Builder {
        private SObject prototype;
        private Template templates;
        private Randomizer randomizer;

        public RecordBuilder(SObject prototype) {
            this.prototype = prototype;
        }

        public RecordBuilder(Template templates) {
            this.prototype = templates.defaultTemplate();
            this.templates = templates;
        }

        public virtual RecordBuilder set(SObjectField field, Object value) {
            this.prototype.put(field, value);
            return this;
        }

        public virtual RecordBuilder set(String field, Object value) {
            this.prototype.put(field, value);
            return this;
        }

        public virtual RecordBuilder useTemplate(String templateName) {
            if (this.templates == null) {
                throw new TestModuleException('Templates not configured. Use constructor with Template parameter.');
            }

            SObject template = this.templates.templates().get(templateName);

            if (template == null) {
                throw new TestModuleException('Template "' + templateName + '" not found.');
            }

            for (String field : template.getPopulatedFieldsAsMap().keySet()) {
                this.prototype.put(field, template.get(field));
            }

            return this;
        }

        public virtual RecordBuilder useRandomizer(Randomizer randomizer) {
            this.randomizer = randomizer;
            return this;
        }

        public SObject build() {
            return this.prototype;
        }

        public SObject buildAndInsert() {
            insert as system this.prototype;
            return this.prototype;
        }

        public List<SObject> build(Integer amount) {
            List<SObject> records = new List<SObject>();

            for (Integer i = 0; i < amount; i++) {
                SObject cloned = this.prototype.clone(false, true, false, false);

                Map<SObjectField, Object> randomizerValues = this.randomizer?.generate(i) ?? new Map<SObjectField, Object>();

                for (SObjectField field : randomizerValues.keySet()) {
                    cloned.put(field, randomizerValues.get(field) ?? cloned.get(field));
                }

                records.add(cloned);
            }

            return records;
        }

        public List<SObject> buildAndInsert(Integer amount) {
            List<SObject> records = this.build(amount);

            insert as system records;

            return records;
        }
    }

    public abstract class RecordMocker implements Mocker {
        private Map<String, Object> fields = new Map<String, Object>();
        private Map<String, List<SObject>> children = new Map<String, List<SObject>>();
        private Template templates;

        private SObjectType prototypeType;

        public RecordMocker(SObject prototype) {
            this.fields = prototype.getPopulatedFieldsAsMap().clone();
            this.prototypeType = prototype.getSObjectType();
        }

        public RecordMocker(Template templates) {
            this(templates.defaultTemplate());
            this.templates = templates;
        }

        public virtual RecordMocker set(SObjectField field, Object value) {
            return this.set(field.toString(), value);
        }

        public virtual RecordMocker set(String field, Object value) {
            this.fields.put(field, value);
            return this;
        }

        public virtual RecordMocker setChildren(String relationship, List<SObject> records) {
            this.children.put(relationship, records);
            return this;
        }

        public virtual RecordMocker setFakeId() {
            this.fields.put('Id', TestModule.fakeId(this.prototypeType));
            return this;
        }

        public SObject build() {
            Map<String, Object> record = new Map<String, Object>();

            this.setNested(record);
            this.setChildren(record);

            return (SObject) JSON.deserialize(JSON.serialize(record), Type.forName(this.prototypeType.toString()));
        }

        public List<SObject> build(Integer amount) {
            List<SObject> records = new List<SObject>();
            for (Integer i = 0; i < amount; i++) {
                records.add(this.build());
            }
            return records;
        }

        private void setNested(Map<String, Object> record) {
            for (String fieldPath : this.fields.keySet()) {
                this.setNestedValue(record, fieldPath, this.fields.get(fieldPath));
            }
        }

        private void setNestedValue(Map<String, Object> record, String fieldPath, Object value) {
            List<String> parts = fieldPath.split('\\.');
            Map<String, Object> current = record;

            for (Integer i = 0; i < parts.size() - 1; i++) {
                String part = parts[i];

                if (!current.containsKey(part) || current.get(part) == null) {
                    current.put(part, new Map<String, Object>());
                }

                current = (Map<String, Object>) current.get(part);
            }

            current.put(parts[parts.size() - 1], value);
        }

        private void setChildren(Map<String, Object> record) {
            for (String relationship : this.children.keySet()) {
                List<SObject> childRecords = this.children.get(relationship);

                record.put(relationship, new Map<String, Object>{ 'totalSize' => childRecords.size(), 'done' => true, 'records' => JSON.deserializeUntyped(JSON.serialize(childRecords)) });
            }
        }
    }
}
