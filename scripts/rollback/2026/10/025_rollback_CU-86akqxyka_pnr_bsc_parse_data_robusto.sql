/*==============================================================================
  ROLLBACK MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86akqxyka
  Autor        : Devin
  Data         : 2026-10-02
  DescriÃ§Ã£o    : Restaura a definicao vigente de dbo.USPTrataStagingPNRBSC
                 (com INNER JOIN em tb_parametros exigindo 'Habilitar PNR BSC'
                 = 1 por cliente), extraida do PROD via OBJECT_DEFINITION.
  Forward ref  : scripts/forward/2026/10/025_forward_CU-86akqxyka_pnr_bsc_parse_data_robusto.sql
  Objetos      : dbo.USPTrataStagingPNRBSC (CREATE OR ALTER PROCEDURE)
  ==============================================================================*/

SET NOCOUNT ON;

BEGIN TRY
    --==========================================================================
    -- 1. PRE-CHECKS
    --==========================================================================
    IF NOT EXISTS (SELECT 1 FROM sys.procedures WHERE object_id = OBJECT_ID('dbo.USPTrataStagingPNRBSC'))
        THROW 50059, 'Procedure dbo.USPTrataStagingPNRBSC nao encontrada.', 1;
END TRY
BEGIN CATCH
    PRINT 'ERRO (pre-check): ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO
CREATE OR ALTER PROCEDURE [dbo].[USPTrataStagingPNRBSC] AS BEGIN SET NOCOUNT ON; SET XACT_ABORT ON; ;WITH limite AS (SELECT MaxExtracao = MAX(DataExtracao) FROM dbo.tb_looker_pnr WITH (NOLOCK)), src AS (SELECT lkp.CodigoCliente, lkp.CASO, lkp.CLA_CLAIM_ID, lkp.STATUS, lkp.CASE_STATUS, lkp.SHIPMENT, lkp.ROUTE_ID, lkp.DRIVER, lkp.VEICULO_ID, lkp.REP_ID, lkp.MLP, lkp.DataExtracao, DhOcorrencia = TRY_CAST(CONCAT(TRY_CAST(SUBSTRING(lkp.DATA, CHARINDEX(',', lkp.DATA) - 4, 4) AS int), '-', RIGHT('0' + CAST(CASE LOWER(REPLACE(SUBSTRING(lkp.DATA, CHARINDEX(' de ', lkp.DATA) + 4, 4), '.', '')) WHEN 'jan' THEN 1 WHEN 'fev' THEN 2 WHEN 'mar' THEN 3 WHEN 'abr' THEN 4 WHEN 'mai' THEN 5 WHEN 'jun' THEN 6 WHEN 'jul' THEN 7 WHEN 'ago' THEN 8 WHEN 'set' THEN 9 WHEN 'out' THEN 10 WHEN 'nov' THEN 11 WHEN 'dez' THEN 12 END AS varchar(2)), 2), '-', RIGHT('0' + CAST(TRY_CAST(LEFT(lkp.DATA, CHARINDEX(' de ', lkp.DATA) - 1) AS int) AS varchar(2)), 2), ' ', LTRIM(RTRIM(SUBSTRING(lkp.DATA, CHARINDEX(',', lkp.DATA) + 1, 20)))) AS datetime), ValorPnr = TRY_CAST(REPLACE(LTRIM(RTRIM(lkp.BPP)), ',', '.') AS DECIMAL(18, 2)), Svc = CASE WHEN lkp.SVC IS NULL THEN NULL WHEN LTRIM(RTRIM(lkp.SVC)) = '' THEN NULL WHEN LOWER(LTRIM(RTRIM(lkp.SVC))) IN ('undefined', 'null', 'n/a') THEN NULL ELSE LEFT(LTRIM(RTRIM(lkp.SVC)), 10) END, rn = ROW_NUMBER() OVER (PARTITION BY lkp.CodigoCliente, lkp.SHIPMENT ORDER BY lkp.DataExtracao DESC, CASE WHEN lkp.ROUTE_ID IS NOT NULL THEN 0 ELSE 1 END, TRY_CAST(REPLACE(LTRIM(RTRIM(lkp.BPP)), ',', '.') AS DECIMAL(18, 2)) DESC) FROM dbo.tb_looker_pnr lkp WITH (NOLOCK) INNER JOIN dbo.tb_parametros prm WITH (NOLOCK) ON prm.prm_cod_cliente = lkp.CodigoCliente AND prm.prm_ds_categoria = N'Financeiro - Pagamentos' AND prm.prm_nm_parametro = N'Habilitar PNR BSC' AND prm.prm_ds_valor = N'1' AND ISNULL(prm.prm_in_ativo, 0) = 1 AND ISNULL(prm.prm_in_excluido, 0) = 0 CROSS JOIN limite lm WHERE lkp.SHIPMENT IS NOT NULL AND lkp.DataExtracao >= DATEADD(DAY, -30, lm.MaxExtracao)) MERGE dbo.tb_pnr_bsc AS dst USING (SELECT * FROM src WHERE rn = 1) AS s ON dst.pnr_cd_cliente = s.CodigoCliente AND dst.pnr_cd_pacote = s.SHIPMENT WHEN MATCHED AND dst.pnr_in_processado = 0 AND ISNULL(s.DataExtracao, '1900-01-01') > ISNULL(dst.pnr_dt_extracao, '1900-01-01') THEN UPDATE SET dst.pnr_cd_caso = s.CASO, dst.pnr_cd_claim = s.CLA_CLAIM_ID, dst.pnr_ds_status = LEFT(s.STATUS, 100), dst.pnr_ds_case_status = LEFT(s.CASE_STATUS, 50), dst.pnr_dh_ocorrencia = s.DhOcorrencia, dst.pnr_dt_extracao = s.DataExtracao, dst.pnr_cd_rota_bsc = s.ROUTE_ID, dst.pnr_cd_motorista_bsc = s.DRIVER, dst.pnr_cd_veiculo_bsc = s.VEICULO_ID, dst.pnr_ds_svc = s.Svc, dst.pnr_ds_rep_id = LEFT(s.REP_ID, 100), dst.pnr_ds_mlp = LEFT(s.MLP, 150), dst.pnr_vl_pnr = s.ValorPnr, dst.pnr_dh_modificacao = GETDATE() WHEN NOT MATCHED BY TARGET THEN INSERT (pnr_cd_cliente, pnr_cd_caso, pnr_cd_claim, pnr_ds_status, pnr_ds_case_status, pnr_dh_ocorrencia, pnr_dt_extracao, pnr_cd_pacote, pnr_cd_rota_bsc, pnr_cd_motorista_bsc, pnr_cd_veiculo_bsc, pnr_ds_svc, pnr_ds_rep_id, pnr_ds_mlp, pnr_vl_pnr) VALUES (s.CodigoCliente, s.CASO, s.CLA_CLAIM_ID, LEFT(s.STATUS, 100), LEFT(s.CASE_STATUS, 50), s.DhOcorrencia, s.DataExtracao, s.SHIPMENT, s.ROUTE_ID, s.DRIVER, s.VEICULO_ID, s.Svc, LEFT(s.REP_ID, 100), LEFT(s.MLP, 150), s.ValorPnr); END
GO
--==========================================================================
-- 3. POS-CHECKS
--==========================================================================
BEGIN TRY
    IF NOT EXISTS (
        SELECT 1 FROM sys.sql_modules sm
        WHERE sm.object_id = OBJECT_ID('dbo.USPTrataStagingPNRBSC')
          AND sm.definition LIKE '%Habilitar PNR BSC%'
    )
        THROW 50060, 'Procedure nao foi restaurada com o filtro de parametro.', 1;

    PRINT 'SUCESSO: Rollback executado com sucesso.';
END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO