@IsTest
public virtual class TestModule {
    private SObject prototype;
    private Map<String, Object> readOnlyFields = new Map<String, Object>();
    private Map<String, List<SObject>> childrenMap = new Map<String, List<SObject>>();
    private Set<SObjectField> uniqueFields = new Set<SObjectField>();
    private Randomizer randomizer;
    private Boolean mockMode = false;

    public TestModule(SObject prototype) {
        this.prototype = prototype;
    }

    protected void setUniqueFields(Set<SObjectField> fields) {
        this.uniqueFields = fields;
    }

    protected virtual Map<String, SObject> variants() {
        return new Map<String, SObject>();
    }

    public TestModule useVariant(String variantName) {
        Map<String, SObject> allVariants = variants();
        if (!allVariants.containsKey(variantName)) {
            throw new TestModuleException(
                'Variant "' + variantName + '" not found'
            );
        }
        this.prototype = allVariants.get(variantName)
            .clone(false, true, false, false);
        return this;
    }

    public TestModule set(SObjectField field, Object value) {
        prototype.put(field, value);
        return this;
    }

    public TestModule set(String field, Object value) {
        prototype.put(field, value);
        return this;
    }

    public TestModule setRandom(SObjectField field, Generator generator) {
        if (this.randomizer == null) {
            this.randomizer = new FieldRandomizer();
        }
        if (this.randomizer instanceof FieldRandomizer) {
            ((FieldRandomizer) this.randomizer).addGenerator(field, generator);
        }
        return this;
    }

    public TestModule setRandom(Randomizer randomizer) {
        this.randomizer = randomizer;
        return this;
    }

    public TestModule setReadOnly(String fieldPath, Object value) {
        mockMode = true;
        readOnlyFields.put(fieldPath, value);
        return this;
    }

    public TestModule setChildren(
        String relationshipName,
        List<SObject> children
    ) {
        mockMode = true;
        childrenMap.put(relationshipName, children);
        return this;
    }

    public TestModule setFakeId(SObjectType sot) {
        mockMode = true;
        readOnlyFields.put('Id', fakeId(sot));
        return this;
    }

    public SObject build() {
        runRandomizer(0);
        return processReadOnlyAndChildren(prototype);
    }

    public List<SObject> build(Integer count) {
        List<SObject> records = new List<SObject>();
        for (Integer i = 0; i < count; i++) {
            SObject cloned = prototype.clone(false, true, false, false);
            runRandomizer(cloned, i);
            applyUniqueFieldSuffix(cloned, i);
            records.add(processReadOnlyAndChildren(cloned));
        }
        return records;
    }

    public SObject buildAndInsert() {
        if (mockMode) {
            throw new TestModuleException(
                'Cannot insert record with mock fields (setReadOnly, setChildren, setFakeId). Use build() instead.'
            );
        }
        runRandomizer(0);
        insert as system prototype;
        return prototype;
    }

    public List<SObject> buildAndInsert(Integer count) {
        if (mockMode) {
            throw new TestModuleException(
                'Cannot insert records with mock fields (setReadOnly, setChildren, setFakeId). Use build() instead.'
            );
        }
        List<SObject> records = new List<SObject>();
        for (Integer i = 0; i < count; i++) {
            SObject cloned = prototype.clone(false, true, false, false);
            runRandomizer(cloned, i);
            applyUniqueFieldSuffix(cloned, i);
            records.add(cloned);
        }
        insert as system records;
        return records;
    }

    public static Id fakeId(SObjectType sot) {
        String keyPrefix = sot.getDescribe().getKeyPrefix();
        return Id.valueOf(
            keyPrefix +
                '0'.repeat(12 - String.valueOf(fakeIdCounter).length()) +
                fakeIdCounter++
        );
    }

    private static Integer fakeIdCounter = 1;

    private void runRandomizer(Integer index) {
        runRandomizer(prototype, index);
    }

    private void runRandomizer(SObject record, Integer index) {
        if (randomizer != null) {
            randomizer.apply(record, index);
        }
    }

    private void applyUniqueFieldSuffix(SObject record, Integer index) {
        for (SObjectField field : uniqueFields) {
            Object currentValue = record.get(field);
            if (currentValue instanceof String) {
                record.put(field, (String) currentValue + ' ' + index);
            }
        }
    }

    private SObject processReadOnlyAndChildren(SObject record) {
        if (readOnlyFields.isEmpty() && childrenMap.isEmpty()) {
            return record;
        }

        Map<String, Object> recordMap = (Map<String, Object>) JSON.deserializeUntyped(
            JSON.serialize(record)
        );

        for (String fieldPath : readOnlyFields.keySet()) {
            setNestedValue(recordMap, fieldPath, readOnlyFields.get(fieldPath));
        }

        for (String relationship : childrenMap.keySet()) {
            List<SObject> children = childrenMap.get(relationship);
            List<Object> childMaps = new List<Object>();
            for (SObject child : children) {
                childMaps.add(JSON.deserializeUntyped(JSON.serialize(child)));
            }
            recordMap.put(
                relationship,
                new Map<String, Object>{
                    'totalSize' => children.size(),
                    'done' => true,
                    'records' => childMaps
                }
            );
        }

        return (SObject) JSON.deserialize(
            JSON.serialize(recordMap),
            SObject.class
        );
    }

    private void setNestedValue(
        Map<String, Object> recordMap,
        String fieldPath,
        Object value
    ) {
        List<String> parts = fieldPath.split('\\.');
        Map<String, Object> current = recordMap;

        for (Integer i = 0; i < parts.size() - 1; i++) {
            String part = parts[i];
            if (!current.containsKey(part) || current.get(part) == null) {
                current.put(part, new Map<String, Object>());
            }
            current = (Map<String, Object>) current.get(part);
        }

        current.put(parts[parts.size() - 1], value);
    }

    public interface Randomizer {
        void apply(SObject record, Integer index);
    }

    public interface Generator {
        Object generate(Integer index);
    }

    private class FieldRandomizer implements Randomizer {
        private Map<SObjectField, Generator> generators = new Map<SObjectField, Generator>();

        public void addGenerator(SObjectField field, Generator generator) {
            generators.put(field, generator);
        }

        public void apply(SObject record, Integer index) {
            for (SObjectField field : generators.keySet()) {
                record.put(field, generators.get(field).generate(index));
            }
        }
    }

    public class Random {
        public static Generator text(Integer length) {
            return new TextGenerator(length);
        }

        public static Generator integer(Integer min, Integer max) {
            return new IntegerGenerator(min, max);
        }

        public static Generator decimal(Decimal min, Decimal max) {
            return new DecimalGenerator(min, max);
        }

        public static Generator email() {
            return new EmailGenerator();
        }

        public static Generator phone() {
            return new PhoneGenerator();
        }

        public static Generator picklistValue(SObjectField field) {
            return new PicklistGenerator(field);
        }

        public static Generator futureDate(Integer minDays, Integer maxDays) {
            return new FutureDateGenerator(minDays, maxDays);
        }
    }

    private class TextGenerator implements Generator {
        private Integer length;
        public TextGenerator(Integer length) {
            this.length = length;
        }
        public Object generate(Integer index) {
            String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
            String result = '';
            for (Integer i = 0; i < length; i++) {
                Integer pos = Math.mod(
                    Math.abs(Crypto.getRandomInteger()),
                    chars.length()
                );
                result += chars.substring(pos, pos + 1);
            }
            return result;
        }
    }

    private class IntegerGenerator implements Generator {
        private Integer min, max;
        public IntegerGenerator(Integer min, Integer max) {
            this.min = min;
            this.max = max;
        }
        public Object generate(Integer index) {
            return min +
                Math.mod(Math.abs(Crypto.getRandomInteger()), (max - min + 1));
        }
    }

    private class DecimalGenerator implements Generator {
        private Decimal min, max;
        public DecimalGenerator(Decimal min, Decimal max) {
            this.min = min;
            this.max = max;
        }
        public Object generate(Integer index) {
            return min + (Math.random() * (max - min));
        }
    }

    private class EmailGenerator implements Generator {
        public Object generate(Integer index) {
            return 'test' +
                index +
                '_' +
                Math.abs(Crypto.getRandomInteger()) +
                '@example.com';
        }
    }

    private class PhoneGenerator implements Generator {
        public Object generate(Integer index) {
            return '+1' +
                String.valueOf(
                    1000000000 +
                    Math.mod(Math.abs(Crypto.getRandomInteger()), 9000000000L)
                );
        }
    }

    private class PicklistGenerator implements Generator {
        private List<String> values = new List<String>();
        public PicklistGenerator(SObjectField field) {
            for (
                Schema.PicklistEntry entry : field.getDescribe()
                    .getPicklistValues()
            ) {
                if (entry.isActive()) {
                    values.add(entry.getValue());
                }
            }
        }
        public Object generate(Integer index) {
            return values[Math.mod(index, values.size())];
        }
    }

    private class FutureDateGenerator implements Generator {
        private Integer minDays, maxDays;
        public FutureDateGenerator(Integer minDays, Integer maxDays) {
            this.minDays = minDays;
            this.maxDays = maxDays;
        }
        public Object generate(Integer index) {
            Integer days =
                minDays +
                Math.mod(
                    Math.abs(Crypto.getRandomInteger()),
                    (maxDays - minDays + 1)
                );
            return Date.today().addDays(days);
        }
    }

    public class TestModuleException extends Exception {
    }
}
