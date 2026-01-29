public virtual class TestModule {
    public interface Builder {
        Builder template(SObject prototype);
        Builder randomize(Randomizer randomizer); 
        Builder set(SObjectField field, Object value);
        Builder set(String field, Object value);
        Builder set(SObjectField field, Builder relatedRecordBuilder);
 
        // TODO Keep it in interface but do not provice implementation so casting will be possible
        SObject build();
        SObject buildAndInsert(); // or buildAndSave()
        List<SObject> buildMany(Integer amount);
        List<SObject> buildAndInsertMany(Integer amount);
    }

    // Mocker
    public interface Mocker {
        
    }

    public interface Randomizer {

    }

    
}