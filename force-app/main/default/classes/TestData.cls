// Note: all names are temporary
public virtual class TestData implements Builder {
    public interface Builder {
       Builder template(SObject prototype);
       Builder randomize(Randomizer randomizer); 
       Builder set(SObjectField field, Object value);
       Builder set(String field, Object value);

       SObject build();
       SObject buildAndInsert(); // or buildAndSave()
       List<SObject> buildMany(Integer amount);
       List<SObject> buildAndInsertMany(Integer amount);
    }
    
    public interface Variants {
    
    }
    
    public interface Randomizer {
    
    }
    
    public static TestData.Builder of(SObjectType type) {
       return new TestData(type);
    }
    
    // Implementation

    private SObjectType type;

    public TestData(SObjectType type) {
       this.type = type;
    }

    public Builder randomize(Randomizer randomizer) {
       return this;
    }

    public Builder template(SObject prototype) {
       return this;
    }

    public Builder set(SObjectField field, Object value) {
       return this;
    }

    public Builder set(String field, Object value) {
       return this;
    }
    
    public SObject build() {
       return new Account();
    }

    public SObject buildAndInsert() {
       return new Account();
    }
    
    
    public List<SObject> buildMany(Integer amount) {
       return new List<SObject>();
    }

    public List<SObject> buildAndInsertMany(Integer amount) {
       return new List<SObject>();
    }
 }