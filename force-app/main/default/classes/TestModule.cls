public virtual class TestModule {

    // Provider interfaces - implemented by test module classes (e.g., AccountTestModule)
    public interface BuilderProvider {
        Builder builder();
    }

    public interface MockerProvider {
        Mocker mocker();
    }

    // Builder interface - defines the contract for building insertable records
    public interface IBuilder {
        Builder set(SObjectField field, Object value);
        Builder set(String field, Object value);
        Builder set(SObjectField field, Builder relatedBuilder);

        SObject build();
        SObject buildAndInsert();
        List<SObject> buildMany(Integer amount);
        List<SObject> buildManyAndInsert(Integer amount);
    }

    // Mocker interface - defines the contract for building non-insertable records
    public interface IMocker {
        Mocker set(SObjectField field, Object value);
        Mocker set(String field, Object value);
        Mocker setChildren(String relationshipName, List<SObject> children);

        SObject build();
        List<SObject> buildMany(Integer amount);
    }

    // Randomizer interface - for generating field values based on index
    public interface IRandomizer {
        Map<SObjectField, Object> randomize(Integer index);
    }

    // Variant interface - for defining named templates/variants
    public interface IVariant {
        Map<String, SObject> variants();
    }

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
