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

        String searchProposta = 'proposta';
        String searchNDA = 'nda';
        String searchDeAcordo = 'de acordo';
        String searchContratoAssinado = 'contrato assinado';

        List<ContentDocumentLink> documentLinks = [SELECT Id, ContentDocumentId, LinkedEntityId, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId IN :ids AND (ContentDocument.Title LIKE :('%' + searchProposta + '%') OR ContentDocument.Title LIKE :('%' + searchNDA + '%') OR ContentDocument.Title LIKE :('%' + searchDeAcordo + '%') OR ContentDocument.Title LIKE :('%' + searchContratoAssinado + '%'))];

        for (Opportunity opp : opportunities) {
            Boolean isNDA = false;
            Boolean isProposta = false;
            Boolean isDeAcordo = false;
            Boolean isContrato = false;
            String titleDoc;
            if (!documentLinks.isEmpty()) {               
                for (ContentDocumentLink file : documentLinks) {
                    titleDoc = file.ContentDocument.Title.toLowerCase();

                    if(file.LinkedEntityId == opp.id && titleDoc.contains(searchProposta)){
                        isProposta = true;
                    }
                    if(file.LinkedEntityId == opp.id && titleDoc.contains(searchNDA)){
                        isNDA = true;
                    }
                    if(file.LinkedEntityId == opp.id && titleDoc.contains(searchDeAcordo)){
                        isDeAcordo = true;
                    }
                    if(file.LinkedEntityId == opp.id && titleDoc.contains(searchContratoAssinado)){
                        isContrato = true;
                    }
                }
            }

            if (opp.StageName == 'Negociação' && (isNDA == false || isProposta == false)) {
                
                opp.addError('Não foi detectado os documentos de NDA ou Proposta. Favor verificar os nomes dos arquivos!');
            }
            if (opp.StageName == 'Formalização' && isDeAcordo == false || (isNDA == false || isProposta == false)) {
                
                opp.addError('Não foi detectado o documento do "De acordo" do cliente ou NDA/Proposta. Favor verificar os nomes dos arquivos!');
            }
            if (opp.StageName == 'Finalizada' && isContrato == false) {
                
                opp.addError('Não foi detectado o documento do "Contrato assinado" do cliente. Favor verificar os nomes dos arquivos!');
            }
        }
    }
}