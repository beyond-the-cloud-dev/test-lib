public with sharing class TestModule {
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
        // SObject buildAndInsert();
        // List<SObject> build(Integer amount);
        // List<SObject> buildAndInsert(Integer amount);
    }

    public interface Mocker {
        Mocker set(SObjectField field, Object value);
        Mocker set(String field, Object value);

        SObject build();
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
    }

    public abstract class RecordMocker implements Mocker {
        private SObject prototype;

        public RecordMocker(SObject prototype) {
            this.prototype = prototype;
        }

        public RecordMocker set(SObjectField field, Object value) {
            this.prototype.put(field, value);
            return this;
        }

        public RecordMocker set(String field, Object value) {
            this.prototype.put(field, value);
            return this;
        }

        public SObject preBuild() {
            return this.prototype;
        }
    }
}
