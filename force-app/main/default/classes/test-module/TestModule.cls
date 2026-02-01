public virtual class TestModule {
    public interface BuilderProvider {
        IBuilder builder();
    }

    public interface MockerProvider {
        IMocker mocker();
    }

    public interface IBuilder {
        IBuilder set(SObjectField field, Object value);
        IBuilder set(String field, Object value);

        SObject build();
        SObject buildAndInsert();
        List<SObject> buildMany(Integer amount);
        List<SObject> buildManyAndInsert(Integer amount);
    }

    public interface IMocker {
        IMocker set(SObjectField field, Object value);
        IMocker set(String field, Object value);
        IMocker setChildren(String relationshipName, List<SObject> children);

        SObject build();
        List<SObject> buildMany(Integer amount);
    }

    public interface IRandomizer {
        Map<SObjectField, Object> randomize(Integer index);
    }

    public interface IVariant {
        Map<String, SObject> variants();
    }

    // Implementation

    public abstract class Builder implements IBuilder {
        private SObject prototype;

        public Builder(SObject prototype) {
            this.prototype = prototype;
        }

        public Builder set(SObjectField field, Object value) {
            this.prototype.put(field, value);
            return this;
        }

        public Builder set(String field, Object value) {
            this.prototype.put(field, value);
            return this;
        }

        public SObject build() {
            return this.prototype;
        }

        public SObject buildAndInsert() {
            insert as system this.prototype;
            return this.prototype;
        }

        public List<SObject> buildMany(Integer amount) {
            return new List<SObject>();
        }

        public List<SObject> buildManyAndInsert(Integer amount) {
            return new List<SObject>();
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

        public Mocker setChildren(String relationshipName, List<SObject> children) {
            this.prototype.put(relationshipName, children);
            return this;
        }

        public SObject build() {
            return this.prototype;
        }

        public List<SObject> buildMany(Integer amount) {
            return new List<SObject>();
        }
    }
}
