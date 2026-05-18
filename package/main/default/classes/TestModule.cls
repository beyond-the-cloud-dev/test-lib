/**
 * Copyright (c) 2026 Beyond The Cloud Sp. z o.o. (BeyondTheCloud.Dev)
 * Licensed under the MIT License (https://github.com/beyond-the-cloud-dev/test-lib/blob/main/LICENSE)
 * 
 * v0.1.0
**/
@IsTest
global class TestModule {
    global interface BuilderProvider {
        Builder Builder();
    }

    global interface MockerProvider {
        Mocker Mocker();
    }

    global interface Builder {
        Builder set(SObjectField field, Object value);
        Builder set(String field, Object value);
        Builder useTemplate(String templateName);
        Builder withRecordType(String recordTypeDeveloperName);
        Builder withRandomizer(TestModule.RecordRandomizer randomizer);
        Builder withRandomizer(SObjectField field, TestModule.FieldRandomizer randomizer);

        SObject build();
        SObject buildAndInsert();
        List<SObject> build(Integer amount);
        List<SObject> buildAndInsert(Integer amount);
    }

    global interface Mocker {
        Mocker set(SObjectField field, Object value);
        Mocker set(String field, Object value); // parent relationships, formulas, rollup sums, etc.
        Mocker setChildren(String relationship, List<SObject> children);
        Mocker setFakeId();
        Mocker withRecordType(String recordTypeDeveloperName);
        Mocker withRandomizer(TestModule.RecordRandomizer randomizer);
        Mocker withRandomizer(SObjectField field, TestModule.FieldRandomizer randomizer);

        SObject build();
        List<SObject> build(Integer amount);
    }

    global interface Template {
        SObject defaultTemplate();
        Map<String, SObject> templates();
    }

    global interface FieldRandomizer {
        Object generate(Integer index);
    }

    global interface RecordRandomizer {
        Map<SObjectField, TestModule.FieldRandomizer> randomizers();
    }

    // Default utilities

    global static final RandomIdGenerator IdGenerator = new RandomIdGenerator();
    global static final RecordTypesInfo RecordTypesInfo = new RecordTypesInfo();

    global static Id fakeId(SObjectType objectType) {
        return IdGenerator.get(objectType);
    }

    global static FieldRandomizer ListRandomizer(List<Object> values) {
        return new ListRandomizer(values);
    }

    global abstract class RecordBuilder implements Builder {
        private SObject prototype;
        private Template templates;
        private RandomizersContainer randomizers = new RandomizersContainer();

        global RecordBuilder(SObject prototype) {
            this.prototype = prototype;
        }

        global RecordBuilder(Template templates) {
            this.prototype = templates.defaultTemplate();
            this.templates = templates;
        }

        global virtual RecordBuilder set(SObjectField field, Object value) {
            this.prototype.put(field, value);
            return this;
        }

        global virtual RecordBuilder set(String field, Object value) {
            this.prototype.put(field, value);
            return this;
        }

        global virtual RecordBuilder useTemplate(String templateName) {
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

        global virtual RecordBuilder withRecordType(String recordTypeDeveloperName) {
            this.prototype.put('RecordTypeId', TestModule.RecordTypesInfo.getId(this.prototype.getSObjectType(), recordTypeDeveloperName));
            return this;
        }

        global virtual RecordBuilder withRandomizer(RecordRandomizer randomizer) {
            this.randomizers.add(randomizer);
            return this;
        }

        global virtual RecordBuilder withRandomizer(SObjectField field, FieldRandomizer randomizer) {
            this.randomizers.add(field, randomizer);
            return this;
        }

        global SObject build() {
            this.randomizers.randomizeFieldsValues(this.prototype, 0);
            return this.prototype;
        }

        global SObject buildAndInsert() {
            insert as system this.prototype;
            return this.prototype;
        }

        global List<SObject> build(Integer amount) {
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

        global List<SObject> buildAndInsert(Integer amount) {
            List<SObject> records = this.build(amount);
            insert as system records;
            return records;
        }
    }

    global abstract class RecordMocker implements Mocker {
        private Map<String, Object> fields = new Map<String, Object>();
        private Map<String, List<SObject>> children = new Map<String, List<SObject>>();
        private Template templates;
        private RandomizersContainer randomizers = new RandomizersContainer();

        private SObjectType prototypeType;

        global RecordMocker(SObject prototype) {
            this.fields = prototype.getPopulatedFieldsAsMap().clone();
            this.prototypeType = prototype.getSObjectType();
        }

        global RecordMocker(Template templates) {
            this(templates.defaultTemplate());
            this.templates = templates;
        }

        global virtual RecordMocker set(SObjectField field, Object value) {
            return this.set(field.toString(), value);
        }

        global virtual RecordMocker set(String field, Object value) {
            this.fields.put(field, value);
            return this;
        }

        global virtual RecordMocker setChildren(String relationship, List<SObject> records) {
            this.children.put(relationship, records);
            return this;
        }

        global virtual RecordMocker setFakeId() {
            this.fields.put('Id', TestModule.IdGenerator.get(this.prototypeType));
            return this;
        }

        global virtual RecordMocker withRecordType(String recordTypeDeveloperName) {
            this.fields.put('RecordTypeId', TestModule.RecordTypesInfo.getId(this.prototypeType, recordTypeDeveloperName));
            return this;
        }

        global virtual RecordMocker withRandomizer(SObjectField field, FieldRandomizer randomizer) {
            this.randomizers.add(field, randomizer);
            return this;
        }

        global virtual RecordMocker withRandomizer(RecordRandomizer randomizer) {
            this.randomizers.add(randomizer);
            return this;
        }

        global SObject build() {
            return this.build(1).get(0);
        }

        global List<SObject> build(Integer amount) {
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

    global class ListRandomizer implements FieldRandomizer {
        private List<Object> values;

        global ListRandomizer(List<Object> values) {
            this.values = values;
        }

        global Object generate(Integer index) {
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

    global class RandomIdGenerator {
        private Integer counter = 0;
        private Map<SObjectType, String> prefixBySObject = new Map<SObjectType, String>();

        global Id get(SObjectType objectType) {
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

    global class RecordTypesInfo {
        private final Map<SObjectType, Map<String, Schema.RecordTypeInfo>> OBJECT_TYPE_TO_RECORD_TYPE_BY_DEVELOPER_NAME = new Map<SObjectType, Map<String, Schema.RecordTypeInfo>>();

        global Id getId(SObjectType objectType, String recordTypeDeveloperName) {
            return byDeveloperName(objectType, recordTypeDeveloperName)?.getRecordTypeId();
        }
    
        private Schema.RecordTypeInfo byDeveloperName(SObjectType objectType, String recordTypeDeveloperName) {
            if (
                !this.OBJECT_TYPE_TO_RECORD_TYPE_BY_DEVELOPER_NAME.containsKey(objectType) ||
                !this.OBJECT_TYPE_TO_RECORD_TYPE_BY_DEVELOPER_NAME.get(objectType).containsKey(recordTypeDeveloperName)
            ) {
                load(objectType);
            }
    
            return this.OBJECT_TYPE_TO_RECORD_TYPE_BY_DEVELOPER_NAME.get(objectType).get(recordTypeDeveloperName);
        }
    
        private void load(SObjectType objectType) {
            Schema.DescribeSObjectResult describe = objectType.getDescribe(SObjectDescribeOptions.DEFERRED);
            this.OBJECT_TYPE_TO_RECORD_TYPE_BY_DEVELOPER_NAME.put(objectType, describe.getRecordTypeInfosByDeveloperName());
        }
    }

    global class TestModuleException extends Exception {
    }
}
