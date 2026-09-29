/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-PENDENTE (hotfix - task a ser aberta; correcao paliativa)
  Autor        : Devin (a pedido de Samuel Nogueira)
  Data         : 2026-09-29
  Descrição    : Corrige mtn_cd_motorista / ppr_cd_motorista / UsuarioIrisys que
                 ficaram apontando para o usr_cd_usuario 7711221 - conta do app
                 que era do motorista CRISTIANO MEDEIROS COSTERMANI, foi deletada
                 e RECICLADA para outras pessoas (Sheila -> Shirlei). Resultado:
                 os espelhos 1575837 (Cristiano, periodo 3641), 1586999 (Sheila
                 Souza Lannes, periodo 3641) e 1548852 (Cristiano, periodo 3564)
                 sao exibidos na tela de Espelhos de Pagamento com o nome
                 "Shirlei", pois a query da tela exibe usr_nm_usuario via
                 INNER JOIN em tb_usuario.

                 Mapeamento correto (verificado em PROD):
                   - CRISTIANO MEDEIROS COSTERMANI -> usr 7722668 (mot 203547)
                   - SHEILA SOUZA LANNES           -> usr 7723347 (mot 204053)
                   - usr 7711221 = Shirlei_Inativo_7711221 (inativo, mot 192703)

                 Escopo (observado em PROD em 2026-09-29):
                   - 3 espelhos (tb_pag_espelhos)
                   - 14 linhas tb_pgto_periodo_rota (9 no per. 3641 + 5 no 3564)
                   - 8 rotas tb_spe_rotas_v5 com UsuarioIrisys = 7711221
                     (todas do Cristiano; corrigir evita re-carimbo em reprocesso)
  Rollback     : scripts/rollback/2026/09/011_rollback_hotfix_espelho_motorista_usr_reciclado.sql
  Objetos      : DML - tb_pag_espelhos, tb_pgto_periodo_rota, tb_spe_rotas_v5
  Dependências : Tela de Espelhos de Pagamento (DriverInvoiceRepository) faz
                 INNER JOIN tb_usuario ON mtn_cd_motorista = usr_cd_usuario
  ==============================================================================*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY

    --==========================================================================
    -- 1. PRE-CHECKS
    --==========================================================================
    -- Usuarios de destino devem existir e estar ativos
    IF NOT EXISTS (SELECT 1 FROM tb_usuario WHERE usr_cd_usuario = 7722668 AND usr_in_ativo = 1)
        THROW 50001, 'PRE-CHECK: usr 7722668 (Cristiano) nao encontrado ou inativo.', 1;

    IF NOT EXISTS (SELECT 1 FROM tb_usuario WHERE usr_cd_usuario = 7723347 AND usr_in_ativo = 1)
        THROW 50002, 'PRE-CHECK: usr 7723347 (Sheila) nao encontrado ou inativo.', 1;

    -- Nome do usuario de destino deve bater com o nome gravado no espelho
    IF NOT EXISTS (
        SELECT 1
        FROM tb_pag_espelhos e
        JOIN tb_usuario u ON u.usr_cd_usuario = 7722668
        WHERE e.mtn_cd_motorista_nfs IN (1575837, 1548852)
          AND e.mtn_nome_motorista = u.usr_nm_usuario
    )
        THROW 50003, 'PRE-CHECK: nome do usr 7722668 diverge de mtn_nome_motorista (Cristiano).', 1;

    IF NOT EXISTS (
        SELECT 1
        FROM tb_pag_espelhos e
        JOIN tb_usuario u ON u.usr_cd_usuario = 7723347
        WHERE e.mtn_cd_motorista_nfs = 1586999
          AND e.mtn_nome_motorista = u.usr_nm_usuario
    )
        THROW 50004, 'PRE-CHECK: nome do usr 7723347 diverge de mtn_nome_motorista (Sheila).', 1;

    --==========================================================================
    -- 2. SCRIPT PRINCIPAL (em transacao - ou corrige tudo ou nada)
    --==========================================================================
    BEGIN TRAN;

    ---------------------------------------------------------------------------
    -- 2a. tb_pag_espelhos - reponta o usuario de cada espelho
    ---------------------------------------------------------------------------
    UPDATE e
    SET e.mtn_cd_motorista = 7722668
    FROM tb_pag_espelhos e
    WHERE e.mtn_cd_motorista_nfs IN (1575837, 1548852)
      AND e.mtn_cd_motorista = 7711221;          -- esperado: 2 linhas (Cristiano)

    UPDATE e
    SET e.mtn_cd_motorista = 7723347
    FROM tb_pag_espelhos e
    WHERE e.mtn_cd_motorista_nfs = 1586999
      AND e.mtn_cd_motorista = 7711221;          -- esperado: 1 linha (Sheila)

    ---------------------------------------------------------------------------
    -- 2b. tb_pgto_periodo_rota - mesmo usuario nas linhas de rota do espelho
    ---------------------------------------------------------------------------
    UPDATE p
    SET p.ppr_cd_motorista = 7722668
    FROM tb_pgto_periodo_rota p
    WHERE p.ppr_cd_motorista = 7711221
      AND p.ppr_cd_pgto_espelho IN (1575837, 1548852);  -- esperado: 8 linhas

    UPDATE p
    SET p.ppr_cd_motorista = 7723347
    FROM tb_pgto_periodo_rota p
    WHERE p.ppr_cd_motorista = 7711221
      AND p.ppr_cd_pgto_espelho = 1586999;              -- esperado: 6 linhas

    ---------------------------------------------------------------------------
    -- 2c. tb_spe_rotas_v5 - corrige a FONTE (UsuarioIrisys) das rotas do
    --     Cristiano, senao um reprocesso recarimba 7711221
    ---------------------------------------------------------------------------
    UPDATE r
    SET r.UsuarioIrisys = 7722668
    FROM tb_spe_rotas_v5 r
    WHERE r.UsuarioIrisys = 7711221
      AND r.Motorista = 'CRISTIANO MEDEIROS COSTERMANI'; -- esperado: 8 linhas

    --==========================================================================
    -- 3. POS-CHECKS
    --==========================================================================
    IF EXISTS (
        SELECT 1 FROM tb_pag_espelhos
        WHERE mtn_cd_motorista = 7711221
          AND mtn_cd_motorista_nfs IN (1575837, 1586999, 1548852)
    )
        THROW 50005, 'POS-CHECK: ainda ha espelho apontando para usr 7711221.', 1;

    IF EXISTS (
        SELECT 1 FROM tb_pgto_periodo_rota
        WHERE ppr_cd_motorista = 7711221
          AND ppr_cd_pgto_espelho IN (1575837, 1586999, 1548852)
    )
        THROW 50006, 'POS-CHECK: ainda ha rota de pagamento apontando para usr 7711221.', 1;

    IF EXISTS (
        SELECT 1 FROM tb_spe_rotas_v5
        WHERE UsuarioIrisys = 7711221
          AND Motorista = 'CRISTIANO MEDEIROS COSTERMANI'
    )
        THROW 50007, 'POS-CHECK: ainda ha rota Shopee do Cristiano com UsuarioIrisys 7711221.', 1;

    COMMIT TRAN;
    PRINT 'SUCESSO: Script executado com sucesso.';

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
