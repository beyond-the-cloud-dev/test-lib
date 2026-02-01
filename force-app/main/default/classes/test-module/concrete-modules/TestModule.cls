public with sharing class TestModule {
    public interface BuilderProvider {
        IBuilder builder();
    }

    public interface MockerProvider {
        IMocker mocker();
    }

    public interface IBuilder {
        IBuilder set(SObjectField field, Object value);
        IBuilder set(String field, Object value);
        IBuilder useTemplate(String templateName);

        SObject build();
    }

    public interface IMocker {
        IMocker set(SObjectField field, Object value);
        IMocker set(String field, Object value);

        SObject build();
    }

    public interface Template {
        SObject defaultTemplate();
        Map<String, SObject> templates();
    }

    public abstract class Builder implements IBuilder {
        private SObject prototype;
        private Template templates;

        public Builder(SObject prototype) {
            this.prototype = prototype;
        }

        public Builder(Template templates) {
            this.templates = templates;
        }

        public Builder withTemplate(Template templates) {
            this.prototype = templates.defaultTemplate();
            this.templates = templates;
            return this;
        }

        public Builder set(SObjectField field, Object value) {
            this.prototype.put(field, value);
            return this;
        }

        public Builder set(String field, Object value) {
            this.prototype.put(field, value);
            return this;
        }

        public Builder useTemplate(String templateName) {
            // TODO merge, not override
            this.prototype = this.templates.templates().get(templateName);
            return this;
        }

        public SObject preBuild() {
            return this.prototype;
        }
    }

    public abstract class Mocker implements IMocker {
        private SObject prototype;

        public Mocker(SObject prototype) {
            this.prototype = prototype;
        }

        public Mocker set(SObjectField field, Object value) {
            this.prototype.put(field, value);
            return this;
        }

        public Mocker set(String field, Object value) {
            this.prototype.put(field, value);
            return this;
        }

        public SObject preBuild() {
            return this.prototype;
        }
    }
}