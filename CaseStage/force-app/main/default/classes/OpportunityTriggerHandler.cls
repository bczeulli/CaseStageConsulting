public class OpportunityTriggerHandler {

    public static void customerType(List<Opportunity> opportunities){
        Set<Id> ids = new Set<Id>();
        for (Opportunity opp : opportunities) {
            ids.add(opp.AccountId);
        }

        List<Opportunity> opps = [SELECT Id, AccountId FROM Opportunity WHERE AccountId =: ids];

        for (Opportunity opp : opportunities) {
            Boolean isFirstProject = true;          
            for (Opportunity currentOpp : opps) {
                if(currentOpp.AccountId == opp.AccountId){
                    opp.Type = 'Cliente recorrente';
                    isFirstProject = false;
                    break;
                }
            }
            if (isFirstProject) {
                opp.Type = 'Primeiro projeto';
            }
        }
    }

    public static void verifyFiles(List<Opportunity> opportunities){
        Set<Id> ids = new Set<Id>();
        for (Opportunity opp : opportunities) {
            ids.add(opp.Id);
        }

        String searchString1 = 'Proposta';
        String searchString2 = 'NDA';
        String searchString3 = 'De acordo';
        String searchString4 = 'Contrato assinado';

        List<ContentDocumentLink> documentLinks = [SELECT Id, ContentDocumentId, LinkedEntityId, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId = :ids AND (ContentDocument.Title LIKE :('%' + searchString1 + '%') OR ContentDocument.Title LIKE :('%' + searchString2 + '%') OR ContentDocument.Title LIKE :('%' + searchString3 + '%') OR ContentDocument.Title LIKE :('%' + searchString4 + '%'))];

        for (Opportunity opp : opportunities) {
            Boolean isNDA = false;
            Boolean isProposta = false;
            Boolean isDeAcordo = false;
            Boolean isContrato = false;
            if (!documentLinks.isEmpty()) {
                for (ContentDocumentLink file : documentLinks) {
                    if(file.LinkedEntityId == opp.id && file.ContentDocument.Title.contains(searchString1)){
                        isProposta = true;
                    }
                    if(file.LinkedEntityId == opp.id && file.ContentDocument.Title.contains(searchString2)){
                        isNDA = true;
                    }
                    if(file.LinkedEntityId == opp.id && file.ContentDocument.Title.contains(searchString3)){
                        isDeAcordo = true;
                    }
                    if(file.LinkedEntityId == opp.id && file.ContentDocument.Title.contains(searchString4)){
                        isDeAcordo = true;
                    }
                }
            }

            if (opp.StageName == 'Negociação' && (isNDA == false || isProposta == false)) {
                
                opp.addError('Não foi detectado os documentos de NDA ou Proposta. Favor verificar os nomes dos arquivos!');
            }
            if (opp.StageName == 'Formalização' && isDeAcordo == false) {
                
                opp.addError('Não foi detectado o documento do "De acordo" do cliente. Favor verificar os nomes dos arquivos!');
            }
            if (opp.StageName == 'Finalizada' && isContrato == false) {
                
                opp.addError('Não foi detectado o documento do "Contrato assinado" do cliente. Favor verificar os nomes dos arquivos!');
            }
        }
    }
}