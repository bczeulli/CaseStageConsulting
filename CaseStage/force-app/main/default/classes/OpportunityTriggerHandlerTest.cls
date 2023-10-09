@isTest
public class OpportunityTriggerHandlerTest {

    @isTest
    static void testCustomerType() {
        List<Opportunity> opps = new  List<Opportunity>();
        // Criação de contas de teste
        Account account1 = TestSetup.getAccount('Conta Teste 1');
        Account account2 = TestSetup.getAccount('Conta Teste 2');
        insert account1;
        insert account2;

        // Criação de oportunidades de teste
        Opportunity opportunity1 = TestSetup.getOpportunity('Oportunidade 1', 'Aberta', account1.Id, 5000);
        Opportunity opportunity2 = TestSetup.getOpportunity('Oportunidade 2', 'Aberta', account1.Id, 5000);
        Opportunity opportunity3 = TestSetup.getOpportunity('Oportunidade 3', 'Aberta', account2.Id, 5000);

        insert opportunity1;
        insert opportunity2;
        insert opportunity3;
        
        Opportunity opp1 = [SELECT id, type, Name FROM Opportunity WHERE Name = 'Oportunidade 1'];
        Opportunity opp2 = [SELECT id, type, Name FROM Opportunity WHERE Name = 'Oportunidade 2'];
        Opportunity opp3 = [SELECT id, type, Name FROM Opportunity WHERE Name = 'Oportunidade 3'];


        // Verifica se o campo Type foi definido corretamente
        System.assertEquals('Primeiro projeto', opp1.Type);
        System.assertEquals('Cliente recorrente', opp2.Type);
        System.assertEquals('Primeiro projeto', opp3.Type);
    }

    @isTest
    static void testVerifyFilesPositive() {
        Account account1 = TestSetup.getAccount('Conta Teste 1');
        insert account1;
        Opportunity opportunity1 = TestSetup.getOpportunity('Oportunidade 1', 'Aberta', account1.Id, 5000);
        insert opportunity1;

        List<ContentDocumentLink> documentLinks = new List<ContentDocumentLink>();
        ContentVersion cv1 = new ContentVersion(
            Description  = 'test description',
            PathOnClient ='Proposta.pdf',
            Title = 'Proposta '+DateTime.now(),
            versiondata=Blob.valueOf('test file body')
        );
        insert cv1;

        ContentVersion cv2 = new ContentVersion(
            Description  = 'test description',
            PathOnClient ='NDA Teste.pdf',
            Title = 'NDA Teste '+DateTime.now(),
            versiondata=Blob.valueOf('test file body')
        );
        insert cv2;

        ContentDocumentLink link1 = new ContentDocumentLink(
            ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv1.Id].ContentDocumentId,
            LinkedEntityId = opportunity1.Id,
            ShareType = 'V'
        );
        ContentDocumentLink link2 = new ContentDocumentLink(
            ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv2.Id].ContentDocumentId,
            LinkedEntityId = opportunity1.Id,
            ShareType = 'V'
        );

        documentLinks.add(link1);
        documentLinks.add(link2);
        insert documentLinks;

        opportunity1.StageName = 'Negociação';
        update opportunity1;

        System.assertEquals(0, opportunity1.getErrors().size(), 'Erro na negociação não deve ser adicionado.');
    }

    @isTest
    static void testVerifyFilesNegotiationNegative() {
        Account account1 = TestSetup.getAccount('Conta Teste 1');
        insert account1;
        Opportunity opportunity1 = TestSetup.getOpportunity('Oportunidade 1', 'Aberta', account1.Id, 5000);
        insert opportunity1;

        opportunity1.StageName = 'Negociação';
        try {
            update opportunity1;
            
        } catch (Exception e) {
            Assert.isTrue(e.getMessage().contains('Não foi detectado os documentos de NDA ou Proposta. Favor verificar os nomes dos arquivos!'), 'Erro em negocição');
        }

    }

    @isTest
    static void testVerifyFilesFomalizationNegative() {
        Account account1 = TestSetup.getAccount('Conta Teste 1');
        insert account1;
        Opportunity opportunity1 = TestSetup.getOpportunity('Oportunidade 1', 'Aberta', account1.Id, 5000);
        insert opportunity1;

        List<ContentDocumentLink> documentLinks = new List<ContentDocumentLink>();
        ContentVersion cv1 = new ContentVersion(
            Description  = 'test description',
            PathOnClient ='contrato assinado.pdf',
            Title = 'contrato assinado '+DateTime.now(),
            versiondata=Blob.valueOf('test file body')
        );
        insert cv1;

        ContentVersion cv2 = new ContentVersion(
            Description  = 'test description',
            PathOnClient ='de acordo Teste.pdf',
            Title = 'de acordo Teste '+DateTime.now(),
            versiondata=Blob.valueOf('test file body')
        );
        insert cv2;

        ContentDocumentLink link1 = new ContentDocumentLink(
            ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv1.Id].ContentDocumentId,
            LinkedEntityId = opportunity1.Id,
            ShareType = 'V'
        );
        ContentDocumentLink link2 = new ContentDocumentLink(
            ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv2.Id].ContentDocumentId,
            LinkedEntityId = opportunity1.Id,
            ShareType = 'V'
        );

        documentLinks.add(link1);
        documentLinks.add(link2);
        insert documentLinks;

        opportunity1.StageName = 'Formalização';

        try {
            update opportunity1;
            
        } catch (Exception e) {
            Assert.isTrue(e.getMessage().contains('Não foi detectado o documento do "De acordo" do cliente ou NDA/Proposta. Favor verificar os nomes dos arquivos!'), 'Erro em formalização');
        }
    }

    @isTest
    static void testVerifyFilesClosedWinNegative() {
        Account account1 = TestSetup.getAccount('Conta Teste 1');
        insert account1;
        Opportunity opportunity1 = TestSetup.getOpportunity('Oportunidade 1', 'Aberta', account1.Id, 5000);
        insert opportunity1;

        opportunity1.StageName = 'Finalizada';
        try {
            update opportunity1;
            
        } catch (Exception e) {
            Assert.isTrue(e.getMessage().contains('Não foi detectado o documento do "Contrato assinado" do cliente. Favor verificar os nomes dos arquivos!'), 'Erro em Finalização');
        }

    }

}