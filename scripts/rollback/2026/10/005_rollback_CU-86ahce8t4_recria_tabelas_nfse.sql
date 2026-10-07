/*==============================================================================
  ROLLBACK MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86ahce8t4
  Autor        : Devin
  Data         : 2026-10-01
  Descrição    : Restaura as tabelas de mensagens NFSe no schema original de
                 PROD (capturado em 01/10/2026): varchar(max)/nullable, sem
                 PK/UNIQUE/FK. Reinsere os 7 motivos vigentes (mtr_in_ativo
                 NULL como estavam; IDs originais 1-7 via IDENTITY_INSERT).
                 mensagem_cliente tinha 0 linhas — recriada vazia.
  Forward ref  : scripts/forward/2026/10/005_forward_CU-86ahce8t4_recria_tabelas_nfse.sql
  Objetos      : dbo.tb_pag_nfse_motivo_reprovacao,
                 dbo.tb_pag_nfse_mensagem_cliente
  ATENÇÃO      : mensagens de cliente cadastradas após o deploy são perdidas
                 neste rollback (a tabela volta ao estado anterior, vazia).
  ==============================================================================*/

SET NOCOUNT ON;

BEGIN TRY

    IF OBJECT_ID('dbo.tb_pag_nfse_mensagem_cliente','U') IS NOT NULL
    BEGIN
        IF EXISTS (SELECT 1 FROM sys.tables WHERE name='tb_pag_nfse_mensagem_cliente' AND temporal_type=2)
            ALTER TABLE dbo.tb_pag_nfse_mensagem_cliente SET (SYSTEM_VERSIONING = OFF);
        DROP TABLE dbo.tb_pag_nfse_mensagem_cliente;
        IF OBJECT_ID('dbo.tb_pag_nfse_mensagem_cliente_hist','U') IS NOT NULL
            DROP TABLE dbo.tb_pag_nfse_mensagem_cliente_hist;
    END

    IF OBJECT_ID('dbo.tb_pag_nfse_motivo_reprovacao','U') IS NOT NULL
        DROP TABLE dbo.tb_pag_nfse_motivo_reprovacao;

    -- Schema original de PROD (01/10/2026)
    CREATE TABLE dbo.tb_pag_nfse_motivo_reprovacao (
        mtr_cd_motivo          int IDENTITY(1,1) NOT NULL,
        mtr_ds_chave           varchar(255) NOT NULL,
        mtr_ds_descricao       varchar(max) NOT NULL,
        mtr_ds_mensagem_padrao varchar(max) NOT NULL,
        mtr_in_ativo           bit          NULL
    );

    CREATE TABLE dbo.tb_pag_nfse_mensagem_cliente (
        mnc_cd_mensagem            int IDENTITY(1,1) NOT NULL,
        mnc_cod_cliente            int          NOT NULL,
        mnc_cd_motivo              int          NOT NULL,
        mnc_ds_mensagem            varchar(max) NOT NULL,
        mnc_in_ativo               bit          NULL,
        mnc_in_excluido            bit          NULL,
        mnc_cd_usuario_criacao     int          NOT NULL,
        mnc_cd_usuario_modificacao int          NOT NULL,
        mnc_dh_criacao             datetime     NOT NULL,
        mnc_dh_modificacao         datetime     NOT NULL
    );

    -- Restaura os 7 motivos vigentes com os IDs originais
    SET IDENTITY_INSERT dbo.tb_pag_nfse_motivo_reprovacao ON;

    INSERT INTO dbo.tb_pag_nfse_motivo_reprovacao
        (mtr_cd_motivo, mtr_ds_chave, mtr_ds_descricao, mtr_ds_mensagem_padrao, mtr_in_ativo)
    VALUES
        (1,'VALOR_TOLERANCIA',       'Valor fora da tolerancia',       'Recusado: valor do espelho está fora da tolerância permitida.',                  NULL),
        (2,'DATA_EMISSAO',           'Data de emissao da NFSe',        'Recusado: data de emissão da NFSe não corresponde ao período de pagamento.',     NULL),
        (3,'CNPJ_TOMADOR',           'CNPJ do tomador',                'Recusado: CNPJ do tomador da NFSe não confere com o cadastro da empresa.',       NULL),
        (4,'CEP',                    'CEP do tomador',                 'Recusado: CEP informado na NFSe não corresponde ao cadastro da empresa.',        NULL),
        (5,'CNPJ_EMITENTE_FORMATO',  'CNPJ do emitente (formato)',     'Recusado: CNPJ do emitente da NFSe inválido ou em formato incorreto.',           NULL),
        (6,'CNPJ_EMITENTE_CADASTRO', 'CNPJ do emitente (cadastro)',    'Recusado: CNPJ do emitente da NFSe é divergente do cadastro do motorista',       NULL),
        (7,'COD_SERVICO',            'Codigo de servico',              'Recusado: código de serviço da NFSe não está na lista permitida.',               NULL);

    SET IDENTITY_INSERT dbo.tb_pag_nfse_motivo_reprovacao OFF;

    IF (SELECT COUNT(*) FROM dbo.tb_pag_nfse_motivo_reprovacao) <> 7
        THROW 50004, 'Rollback: esperava 7 motivos restaurados.', 1;

    PRINT 'SUCESSO: Tabelas NFSe restauradas no schema original com os 7 motivos vigentes.';

END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Severidade: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
    THROW;
END CATCH;
GO
