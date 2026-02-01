@IsTest
public class OpportunityTestModule implements TestModule.BuilderProvider, TestModule.MockerProvider {
    public static OpportunityBuilder Builder() {
        return new OpportunityBuilder();
    }

    public static OpportunityMocker Mocker() {
        return new OpportunityMocker();
    }

    public class OpportunityBuilder extends TestModule.RecordBuilder {
        public OpportunityBuilder() {
            super(new Templates());
        }

        public OpportunityBuilder withName(String name) {
            super.set(Opportunity.Name, name);
            return this;
        }

        public OpportunityBuilder withStageName(String stageName) {
            super.set(Opportunity.StageName, stageName);
            return this;
        }

        public OpportunityBuilder withCloseDate(Date closeDate) {
            super.set(Opportunity.CloseDate, closeDate);
            return this;
        }

        public OpportunityBuilder withAmount(Decimal amount) {
            super.set(Opportunity.Amount, amount);
            return this;
        }

        public OpportunityBuilder prospecting() {
            super.useTemplate('prospecting');
            return this;
        }

        public OpportunityBuilder closedWon() {
            super.useTemplate('closedWon');
            return this;
        }

        public Opportunity build() {
            return (Opportunity) super.preBuild();
        }

        public Opportunity buildAndInsert() {
            return (Opportunity) super.preBuildAndInsert();
        }
    }

    public class OpportunityMocker extends TestModule.RecordMocker {
        public OpportunityMocker() {
            super(new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today().addDays(30)));
        }

        public Opportunity build() {
            return (Opportunity) super.preBuild();
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
}