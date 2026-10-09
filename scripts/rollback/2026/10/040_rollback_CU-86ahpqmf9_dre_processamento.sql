/*==============================================================================
  ROLLBACK MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86ahpqmf9
  Autor        : Samuel Nogueira (Devin)
  Data         : 2026-10-09
  Descricao    : Reverte o deploy 040 — gestao de periodos DRE.
                 1) Dropa trigger, procedures e recria tb_fin_dre_processamento
                    no formato original do deploy 039 (PK composta, sem dados —
                    a tabela estava vazia quando o 040 foi aplicado).
                 ATENCAO: se periodos ja tiverem sido gerados pelo 040, os
                 registros de tb_fin_dre_processamento serao perdidos (a fato
                 e o log de carga NAO sao afetados).
  Forward      : scripts/forward/2026/10/040_forward_CU-86ahpqmf9_dre_processamento.sql
  ==============================================================================*/

SET NOCOUNT ON;
GO

BEGIN TRY
    IF OBJECT_ID('dbo.trg_aud_dre_processamento', 'TR') IS NOT NULL
        DROP TRIGGER dbo.trg_aud_dre_processamento;

    IF OBJECT_ID('dbo.sp_fin_dre_gerar_periodo', 'P') IS NOT NULL
        DROP PROCEDURE dbo.sp_fin_dre_gerar_periodo;

    IF OBJECT_ID('dbo.sp_fin_dre_periodo_status', 'P') IS NOT NULL
        DROP PROCEDURE dbo.sp_fin_dre_periodo_status;

    IF OBJECT_ID('dbo.tb_fin_dre_processamento', 'U') IS NOT NULL
        DROP TABLE dbo.tb_fin_dre_processamento;

    -- Recria no formato do deploy 039 (PK composta)
    CREATE TABLE dbo.tb_fin_dre_processamento (
        CodCliente   int         NOT NULL,
        Ano          int         NOT NULL,
        Mes          tinyint     NOT NULL,
        CodVisao     smallint    NOT NULL,
        Status       varchar(20) NOT NULL,   -- SIMULACAO | PROCESSADO
        DhGeracao    datetime    NOT NULL CONSTRAINT DF_dre_proc_geracao DEFAULT SYSDATETIME(),
        DhProcessado datetime    NULL,
        UsuarioApp   varchar(100) NULL,
        CONSTRAINT PK_dre_processamento PRIMARY KEY (CodCliente, Ano, Mes, CodVisao)
    );

    PRINT 'Rollback 040 concluido.';
END TRY
BEGIN CATCH
    PRINT 'ERRO NO ROLLBACK 040: ' + ERROR_MESSAGE();
    THROW;
END CATCH
GO
