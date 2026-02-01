@IsTest
public class TestModule {
    public interface BuilderProvider {
        Builder builder();
    }

    public interface MockerProvider {
        Mocker mocker();
    }

    public interface Builder {
        Builder set(SObjectField field, Object value);
        Builder set(String field, Object value);
        Builder useTemplate(String templateName);

        SObject build();
        SObject buildAndInsert();
        List<SObject> build(Integer amount);
        List<SObject> buildAndInsert(Integer amount);
    }

    public interface Mocker {
        Mocker set(SObjectField field, Object value);
        Mocker set(String field, Object value);
        Mocker setChildren(String relationship, List<SObject> children);

        SObject build();
        List<SObject> build(Integer amount);
    }

    public interface Template {
        SObject defaultTemplate();
        Map<String, SObject> templates();
    }

    public abstract class RecordBuilder implements Builder {
        private SObject prototype;
        private Template templates;

        public RecordBuilder(SObject prototype) {
            this.prototype = prototype;
        }

        public RecordBuilder(Template templates) {
            this.prototype = templates.defaultTemplate();
            this.templates = templates;
        }

        public RecordBuilder set(SObjectField field, Object value) {
            this.prototype.put(field, value);
            return this;
        }

        public RecordBuilder set(String field, Object value) {
            this.prototype.put(field, value);
            return this;
        }

        public RecordBuilder useTemplate(String templateName) {
            // TODO merge, not override
            this.prototype = this.templates.templates().get(templateName);
            return this;
        }

        public SObject preBuild() {
            return this.prototype;
        }

        public SObject preBuildAndInsert() {
            insert as system this.prototype;
            return this.prototype;
        }

        public List<SObject> build(Integer amount) {
            List<SObject> records = new List<SObject>();

            for (Integer i = 0; i < amount; i++) {
                records.add(this.prototype.clone(false, true, false, false));
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

        public RecordMocker set(SObjectField field, Object value) {
            return this.set(field.toString(), value);
        }

        public RecordMocker set(String field, Object value) {
            this.fields.put(field, value);
            return this;
        }

        public RecordMocker setChildren(String relationship, List<SObject> records) {
            this.children.put(relationship, records);
            return this;
        }

        public SObject preBuild() {
            Map<String, Object> record = new Map<String, Object>();

            this.setNested(record);
            this.setChildren(record);

            return (SObject) JSON.deserialize(JSON.serialize(record), Type.forName(this.prototypeType.toString()));
        }

        public List<SObject> build(Integer amount) {
            return new List<SObject>();
        }

        private void setNested(Map<String, Object> record) {
            for (String fieldPath : this.fields.keySet()) {
                List<String> parts = fieldPath.split('\\.');

                for (Integer i = 0; i < parts.size() - 1; i++) {
                    String part = parts[i];

                    if (!record.containsKey(part) || record.get(part) == null) {
                        record.put(part, new Map<String, Object>());
                    }

                    record = (Map<String, Object>) record.get(part);
                }

                record.put(parts[parts.size() - 1], this.fields.get(fieldPath));
            }
        }

        private void setChildren(Map<String, Object> record) {
            for (String relationship : this.children.keySet()) {
                List<SObject> children = this.children.get(relationship);

                record.put(relationship, new Map<String, Object>{ 'totalSize' => children.size(), 'done' => true, 'records' => JSON.deserializeUntyped(JSON.serialize(children)) });
            }
        }
    }
}
