@IsTest
public class OpportunityTestModule implements TestModule.BuilderProvider, TestModule.MockerProvider {
    public static Builder Builder() {
        return new Builder();
    }

    public static Mocker Mocker() {
        return new Mocker();
    }

    public class Builder extends TestModule.RecordBuilder {
        private Builder() {
            super(new Templates());
        }

        public Builder withName(String name) {
            super.set(Opportunity.Name, name);
            return this;
        }

        public Builder withStageName(String stageName) {
            super.set(Opportunity.StageName, stageName);
            return this;
        }

        public Builder withCloseDate(Date closeDate) {
            super.set(Opportunity.CloseDate, closeDate);
            return this;
        }

        public Builder withAmount(Decimal amount) {
            super.set(Opportunity.Amount, amount);
            return this;
        }

        public Builder prospecting() {
            super.useTemplate('prospecting');
            return this;
        }

        public Builder closedWon() {
            super.useTemplate('closedWon');
            return this;
        }

        public Builder withOpportunityRandomizer() {
            super.withRandomizer(new OpportunityRandomizer());
            return this;
        }
    }

    private class Mocker extends TestModule.RecordMocker {
        private Mocker() {
            super(new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today().addDays(30)));
        }

        public Mocker withName(String name) {
            super.set(Opportunity.Name, name);
            return this;
        }

        public Mocker withStageName(String stageName) {
            super.set(Opportunity.StageName, stageName);
            return this;
        }

        public Mocker withCloseDate(Date closeDate) {
            super.set(Opportunity.CloseDate, closeDate);
            return this;
        }

        public Mocker withAmount(Decimal amount) {
            super.set(Opportunity.Amount, amount);
            return this;
        }

        public Mocker withAccountName(String accountName) {
            super.set('Account.Name', accountName);
            return this;
        }

        public Mocker withFakeId() {
            super.setFakeId();
            return this;
        }

        public Mocker withOpportunityRandomizer() {
            super.withRandomizer(new OpportunityRandomizer());
            return this;
        }
    }

    public class Templates implements TestModule.Template {
        public SObject defaultTemplate() {
            return new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today().addDays(30));
        }

        public Map<String, SObject> templates() {
            return new Map<String, SObject>{
                'prospecting' => new Opportunity(Name = 'Prospecting Opportunity', StageName = 'Prospecting', CloseDate = Date.today().addDays(30)),
                'closedWon' => new Opportunity(Name = 'Closed Won Opportunity', StageName = 'Closed Won', CloseDate = Date.today(), Amount = 100000)
            };
        }
    }

    public class OpportunityRandomizer implements TestModule.RecordRandomizer {
        public Map<SObjectField, TestModule.FieldRandomizer> randomizers() {
            return new Map<SObjectField, TestModule.FieldRandomizer>{
                Opportunity.Name => new OpportunityNameRandomizer(),
                Opportunity.Amount => new AmountRandomizer()
            };
        }
    }

    public class OpportunityNameRandomizer implements TestModule.FieldRandomizer {
        public Object generate(Integer index) {
            return 'Opportunity ' + (index + 1);
        }
    }

    public class AmountRandomizer implements TestModule.FieldRandomizer {
        public Object generate(Integer index) {
            return (index + 1) * 50000;
        }
    }
}