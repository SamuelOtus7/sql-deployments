/*==============================================================================
  ROLLBACK MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-PENDENTE (hotfix - task a ser aberta; correcao paliativa)
  Autor        : Devin (a pedido de Samuel Nogueira)
  Data         : 2026-09-29
  Descrição    : Reverte o forward 011: devolve mtn_cd_motorista /
                 ppr_cd_motorista / UsuarioIrisys para usr_cd_usuario 7711221
                 nos 3 espelhos, 14 linhas de rota de pagamento e 8 rotas
                 Shopee afetadas.
  Forward ref  : scripts/forward/2026/09/011_forward_hotfix_espelho_motorista_usr_reciclado.sql
  Objetos      : DML - tb_pag_espelhos, tb_pgto_periodo_rota, tb_spe_rotas_v5
  ==============================================================================*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY

    --==========================================================================
    -- 1. PRE-CHECKS
    --==========================================================================
    IF NOT EXISTS (
        SELECT 1 FROM tb_pag_espelhos
        WHERE mtn_cd_motorista_nfs IN (1575837, 1586999, 1548852)
          AND mtn_cd_motorista IN (7722668, 7723347)
    )
        THROW 50010, 'PRE-CHECK ROLLBACK: espelhos nao estao no estado pos-forward.', 1;

    --==========================================================================
    -- 2. SCRIPT DE ROLLBACK
    --==========================================================================
    BEGIN TRAN;

    UPDATE e
    SET e.mtn_cd_motorista = 7711221
    FROM tb_pag_espelhos e
    WHERE e.mtn_cd_motorista_nfs IN (1575837, 1548852)
      AND e.mtn_cd_motorista = 7722668;

    UPDATE e
    SET e.mtn_cd_motorista = 7711221
    FROM tb_pag_espelhos e
    WHERE e.mtn_cd_motorista_nfs = 1586999
      AND e.mtn_cd_motorista = 7723347;

    UPDATE p
    SET p.ppr_cd_motorista = 7711221
    FROM tb_pgto_periodo_rota p
    WHERE p.ppr_cd_motorista = 7722668
      AND p.ppr_cd_pgto_espelho IN (1575837, 1548852);

    UPDATE p
    SET p.ppr_cd_motorista = 7711221
    FROM tb_pgto_periodo_rota p
    WHERE p.ppr_cd_motorista = 7723347
      AND p.ppr_cd_pgto_espelho = 1586999;

    UPDATE r
    SET r.UsuarioIrisys = 7711221
    FROM tb_spe_rotas_v5 r
    WHERE r.UsuarioIrisys = 7722668
      AND r.Motorista = 'CRISTIANO MEDEIROS COSTERMANI'
      AND r.DataReferencia BETWEEN '2026-08-23' AND '2026-09-11';

    --==========================================================================
    -- 3. POS-CHECKS
    --==========================================================================
    IF EXISTS (
        SELECT 1 FROM tb_pag_espelhos
        WHERE mtn_cd_motorista_nfs IN (1575837, 1586999, 1548852)
          AND mtn_cd_motorista IN (7722668, 7723347)
    )
        THROW 50011, 'POS-CHECK ROLLBACK: espelhos ainda apontam para usuarios corrigidos.', 1;

    COMMIT TRAN;
    PRINT 'SUCESSO: Rollback executado com sucesso.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN;

    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Severidade: ' + CAST(ERROR_SEVERITY() AS VARCHAR);

    THROW;
END CATCH;
GO
