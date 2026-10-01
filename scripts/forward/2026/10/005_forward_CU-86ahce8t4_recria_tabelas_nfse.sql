/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86ahce8t4
  Autor        : Devin
  Data         : 2026-10-01
  Descrição    : Recria as tabelas de parametrização de mensagens de reprovação
                 de NFSe com o schema definitivo (varchar delimitado, NOT NULL,
                 defaults, PK/UNIQUE/FK). As tabelas já existem em PROD no
                 schema antigo (varchar(max), sem constraints); estão vazias
                 de dados de negócio — motivo tem apenas 7 seeds recriados
                 pelo script 006 e mensagem_cliente tem 0 linhas.
  Rollback     : scripts/rollback/2026/10/005_rollback_CU-86ahce8t4_recria_tabelas_nfse.sql
  Objetos      : dbo.tb_pag_nfse_motivo_reprovacao,
                 dbo.tb_pag_nfse_mensagem_cliente
  Dependências : dbo.vw_espelhos_nfse (alterada no script 008)
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

    CREATE TABLE dbo.tb_pag_nfse_motivo_reprovacao (
        mtr_cd_motivo          int IDENTITY(1,1) PRIMARY KEY,
        mtr_ds_chave           varchar(50)  NOT NULL UNIQUE,
        mtr_ds_descricao       varchar(150) NOT NULL,
        mtr_ds_mensagem_padrao varchar(255) NOT NULL,
        mtr_in_ativo           bit          NOT NULL DEFAULT(1)
    );

    CREATE TABLE dbo.tb_pag_nfse_mensagem_cliente (
        mnc_cd_mensagem            int IDENTITY(1,1) PRIMARY KEY,
        mnc_cod_cliente            int          NOT NULL,
        mnc_cd_motivo              int          NOT NULL REFERENCES dbo.tb_pag_nfse_motivo_reprovacao(mtr_cd_motivo),
        mnc_ds_mensagem            varchar(255) NOT NULL,
        mnc_in_ativo               bit          NOT NULL DEFAULT(1),
        mnc_in_excluido            bit          NOT NULL DEFAULT(0),
        mnc_cd_usuario_criacao     int          NOT NULL,
        mnc_dh_criacao             datetime     NOT NULL DEFAULT(getdate()),
        mnc_cd_usuario_modificacao int          NULL,
        mnc_dh_modificacao         datetime     NULL,
        CONSTRAINT UK_nfse_msg_cliente UNIQUE (mnc_cd_motivo, mnc_cod_cliente)
    );

    IF OBJECT_ID('dbo.tb_pag_nfse_motivo_reprovacao','U') IS NULL
       OR OBJECT_ID('dbo.tb_pag_nfse_mensagem_cliente','U') IS NULL
        THROW 50001, 'Tabelas NFSe nao foram recriadas.', 1;

    PRINT 'SUCESSO: Tabelas NFSe recriadas no schema definitivo.';

END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Severidade: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
    THROW;
END CATCH;
GO
