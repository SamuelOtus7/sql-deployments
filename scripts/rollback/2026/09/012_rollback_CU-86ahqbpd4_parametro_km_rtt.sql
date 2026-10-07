/*==============================================================================
  ROLLBACK MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86ahqbpd4
  Autor        : Devin
  Data         : 2026-09-28
  Descrição    : Reverte o forward 012 (habilitação do parâmetro 'Km RTT').
                 Estado anterior documentado em PROD (2026-09-28): apenas o
                 cliente 27 estava com 'false'; clientes 11, 59, 61, 64, 66 e 73
                 já estavam 'true' antes do forward (não são alterados aqui).
                 Também remove linhas 'Km RTT' inseridas pelo forward para
                 clientes da lista que não possuíam o parâmetro (identificadas
                 por prm_dh_criacao >= '2026-09-28'; as linhas pré-existentes
                 foram criadas em 2025-12-29 e 2026-03-23).
  Forward ref  : scripts/forward/2026/09/012_forward_CU-86ahqbpd4_parametro_km_rtt.sql
  Objetos      : dbo.tb_parametros (dados)
  ==============================================================================*/

SET NOCOUNT ON;

BEGIN TRY
    --==========================================================================
    -- 1. Remove linhas inseridas pelo forward (clientes que não tinham o parâmetro)
    --==========================================================================
    -- Só remove linhas criadas a partir da data do deploy: as pré-existentes
    -- foram criadas em 2025-12-29/2026-03-23, e a uk_parametros
    -- (prm_nm_parametro, prm_cod_cliente) impede duplicidade.
    DELETE p
    FROM dbo.tb_parametros p
    WHERE p.prm_nm_parametro = 'Km RTT'
      AND p.prm_cod_cliente IN (11, 27, 59, 61, 64, 66, 73)
      AND p.prm_dh_criacao >= '2026-09-28';

    --==========================================================================
    -- 2. Restaura o valor anterior do cliente 27 ('false')
    --==========================================================================
    UPDATE p
    SET p.prm_ds_valor              = 'false',
        p.prm_cd_usuario_modificacao = 7,
        p.prm_dh_modificacao         = GETDATE()
    FROM dbo.tb_parametros p
    WHERE p.prm_nm_parametro = 'Km RTT'
      AND p.prm_cod_cliente  = 27;

    --==========================================================================
    -- 3. POS-CHECK
    --==========================================================================
    IF EXISTS (
        SELECT 1
        FROM dbo.tb_parametros p
        WHERE p.prm_nm_parametro = 'Km RTT'
          AND p.prm_cod_cliente  = 27
          AND p.prm_ds_valor     = 'true'
    )
        THROW 50009, 'Pós-check falhou: cliente 27 ainda com Km RTT habilitado.', 1;

    PRINT 'SUCESSO: Rollback executado com sucesso.';

END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Severidade: ' + CAST(ERROR_SEVERITY() AS VARCHAR);

    THROW;
END CATCH;
GO
