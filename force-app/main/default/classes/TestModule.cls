@IsTest
@TestVisible
private class TestModule {
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
        Builder withRandomizer(TestModule.RecordRandomizer randomizer);
        Builder withRandomizer(SObjectField field, TestModule.FieldRandomizer randomizer);

        SObject build();
        SObject buildAndInsert();
        List<SObject> build(Integer amount);
        List<SObject> buildAndInsert(Integer amount);
    }

    public interface Mocker {
        Mocker set(SObjectField field, Object value);
        Mocker set(String field, Object value); // parent relationships, formulas, rollup sums, etc.
        Mocker setChildren(String relationship, List<SObject> children);
        Mocker setFakeId();
        Mocker withRandomizer(TestModule.RecordRandomizer randomizer);
        Mocker withRandomizer(SObjectField field, TestModule.FieldRandomizer randomizer);

        SObject build();
        List<SObject> build(Integer amount);
    }

    public interface Template {
        SObject defaultTemplate();
        Map<String, SObject> templates();
    }

    public interface FieldRandomizer {
        Object generate(Integer index);
    }

    public interface RecordRandomizer {
        Map<SObjectField, TestModule.FieldRandomizer> randomizers();
    }

    // Default utilities

    public static final RandomIdGenerator IdGenerator = new RandomIdGenerator();

    public static Id fakeId(SObjectType objectType) {
        return IdGenerator.get(objectType);
    }

    public static FieldRandomizer ListRandomizer(List<Object> values) {
        return new ListRandomizer(values);
    }

    public abstract class RecordBuilder implements Builder {
        private SObject prototype;
        private Template templates;
        private RandomizersContainer randomizers = new RandomizersContainer();

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

        public virtual RecordBuilder withRandomizer(RecordRandomizer randomizer) {
            this.randomizers.add(randomizer);
            return this;
        }

        public virtual RecordBuilder withRandomizer(SObjectField field, FieldRandomizer randomizer) {
            this.randomizers.add(field, randomizer);
            return this;
        }

        public SObject build() {
            this.randomizers.randomizeFieldsValues(this.prototype, 0);
            return this.prototype;
        }

        public SObject buildAndInsert() {
            insert as system this.prototype;
            return this.prototype;
        }

        public List<SObject> build(Integer amount) {
            List<SObject> records = new List<SObject>();
            this.randomizeFieldsValues(records, amount);
            return records;
        }

        private void randomizeFieldsValues(List<SObject> records, Integer amount) {
            for (Integer i = 0; i < amount; i++) {
                SObject cloned = this.prototype.clone(false, true, false, false);
                this.randomizers.randomizeFieldsValues(cloned, i);
                records.add(cloned);
            }
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
        private RandomizersContainer randomizers = new RandomizersContainer();

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
            this.fields.put('Id', TestModule.IdGenerator.get(this.prototypeType));
            return this;
        }

        public virtual RecordMocker withRandomizer(SObjectField field, FieldRandomizer randomizer) {
            this.randomizers.add(field, randomizer);
            return this;
        }

        public virtual RecordMocker withRandomizer(RecordRandomizer randomizer) {
            this.randomizers.add(randomizer);
            return this;
        }

        public SObject build() {
            return this.build(1).get(0);
        }

        public List<SObject> build(Integer amount) {
            List<SObject> records = new List<SObject>();
            for (Integer i = 0; i < amount; i++) {
                records.add(this.buildWithIndex(i));
            }
            return records;
        }

        private SObject buildWithIndex(Integer index) {
            Map<String, Object> record = new Map<String, Object>();

            this.setNested(record);
            this.setChildren(record);

            this.randomizers.randomizeFieldsValues(record, index);

            return (SObject) JSON.deserialize(JSON.serialize(record), Type.forName(this.prototypeType.toString()));
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

                record.put(
                    relationship,
                    new Map<String, Object>{ 'totalSize' => childRecords.size(), 'done' => true, 'records' => JSON.deserializeUntyped(JSON.serialize(childRecords)) }
                );
            }
        }
    }

    // Default randomizers

    public class ListRandomizer implements FieldRandomizer {
        private List<Object> values;

        public ListRandomizer(List<Object> values) {
            this.values = values;
        }

        public Object generate(Integer index) {
            return values[Math.mod(index, values.size())];
        }
    }

    private class RandomizersContainer {
        private Map<SObjectField, FieldRandomizer> fieldRandomizers = new Map<SObjectField, FieldRandomizer>();

        public RandomizersContainer add(SObjectField field, FieldRandomizer randomizer) {
            this.fieldRandomizers.put(field, randomizer);
            return this;
        }

        public RandomizersContainer add(RecordRandomizer randomizer) {
            for (SObjectField field : randomizer.randomizers().keySet()) {
                this.add(field, randomizer.randomizers().get(field));
            }

            return this;
        }

        public void randomizeFieldsValues(SObject record, Integer index) {
            for (SObjectField field : this.fieldRandomizers.keySet()) {
                Object value = this.fieldRandomizers.get(field).generate(index);

                if (value == null) {
                    continue;
                }

                record.put(field, value);
            }
        }

        public void randomizeFieldsValues(Map<String, Object> record, Integer index) {
            for (SObjectField field : this.fieldRandomizers.keySet()) {
                Object value = this.fieldRandomizers.get(field).generate(index);

                if (value == null) {
                    continue;
                }

                record.put(field.toString(), value);
            }
        }
    }

    // Utilities

    @TestVisible
    private class RandomIdGenerator {
        private Integer counter = 0;
        private Map<SObjectType, String> prefixBySObject = new Map<SObjectType, String>();

        public Id get(SObjectType objectType) {
            return this.get(this.getPrefix(objectType));
        }

        private Id get(String prefix) {
            this.counter++;
            return Id.valueOf(prefix + '0'.repeat(15 - prefix.length() - String.valueOf(this.counter).length()) + String.valueOf(this.counter));
        }

        private String getPrefix(SObjectType objectType) {
            String prefix = this.prefixBySObject.get(objectType);

            if (prefix == null) {
                prefix = objectType.getDescribe().getKeyPrefix();
                this.prefixBySObject.put(objectType, prefix);
            }

            return prefix;
        }
    }

    public class TestModuleException extends Exception {
    }
}
