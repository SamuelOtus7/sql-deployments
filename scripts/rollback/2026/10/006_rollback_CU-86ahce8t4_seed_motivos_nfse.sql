/*==============================================================================
  ROLLBACK MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86ahce8t4
  Autor        : Devin
  Data         : 2026-10-01
  Descrição    : Remove os motivos inseridos pelo seed do forward (4 motivos de
                 regra novos + 14 de erro de integração). Os 7 motivos base já
                 existiam em PROD e são preservados. Mensagens de cliente que
                 referenciem motivos removidos são apagadas antes (FK).
  Forward ref  : scripts/forward/2026/10/006_forward_CU-86ahce8t4_seed_motivos_nfse.sql
  Objetos      : dbo.tb_pag_nfse_motivo_reprovacao (dados),
                 dbo.tb_pag_nfse_mensagem_cliente (dados, somente referências
                 aos motivos removidos)
  ==============================================================================*/

SET NOCOUNT ON;

BEGIN TRY

    DECLARE @remover TABLE (cd_motivo int PRIMARY KEY);

    INSERT INTO @remover (cd_motivo)
    SELECT mtr_cd_motivo
    FROM dbo.tb_pag_nfse_motivo_reprovacao
    WHERE mtr_ds_chave IN (
        'DATA_COMPETENCIA_NULA','DATA_COMPETENCIA','SEM_TOMADOR','EMISSAO_TERCEIRO',
        'ERRO_GENERICO','ARQ_CORROMPIDO','XML_PROCESSADO','DOC_FORA_PADRAO',
        'ERRO_ANALISE','ERRO_BAIXAR_ARQUIVO','ERRO_BAIXAR_PDF','ERRO_API',
        'CHAVE_NAO_ENCONTRADA','XML_NAO_ENCONTRADO','PDF_IMAGEM',
        'PDF_SEM_CONTEUDO','PDF_INVALIDO','PROCESSADO_SUCESSO'
    );

    DELETE mc
    FROM dbo.tb_pag_nfse_mensagem_cliente mc
    JOIN @remover r ON r.cd_motivo = mc.mnc_cd_motivo;

    DELETE m
    FROM dbo.tb_pag_nfse_motivo_reprovacao m
    JOIN @remover r ON r.cd_motivo = m.mtr_cd_motivo;

    PRINT 'SUCESSO: Seed de motivos NFSe removido. Restantes: '
        + CAST((SELECT COUNT(*) FROM dbo.tb_pag_nfse_motivo_reprovacao) AS varchar(10));

END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Severidade: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
    THROW;
END CATCH;
GO
