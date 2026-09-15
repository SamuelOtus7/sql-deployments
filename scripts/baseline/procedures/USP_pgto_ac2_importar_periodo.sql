-- ============================================================
-- BASELINE: dbo.USP_pgto_ac2_importar_periodo
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[USP_pgto_ac2_importar_periodo]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[USP_pgto_ac2_importar_periodo]
    @CodPeriodoPagamento INT
AS
BEGIN
    SET DATEFORMAT DMY;

    DECLARE
          @data_inicial DATE
        , @data_final DATE
        , @clienteid INT
        , @IdTransportadora INT = 1950609251

    INSERT INTO tb_remove_periodo_fligth SELECT @CodPeriodoPagamento

    SET @data_inicial = (SELECT pgp_dt_inicio FROM dbo.tb_pgto_periodo WITH(NOLOCK) WHERE pgp_cd_periodo = @CodPeriodoPagamento)
    SET @data_final   = (SELECT pgp_dt_fim   FROM dbo.tb_pgto_periodo WITH(NOLOCK) WHERE pgp_cd_periodo = @CodPeriodoPagamento)
    SET @clienteid    = (SELECT pgp_cd_cliente FROM dbo.tb_pgto_periodo WHERE pgp_cd_periodo = @CodPeriodoPagamento)

    DROP TABLE IF EXISTS #tb_fin_salarios_profissionais

    SELECT
         @CodPeriodoPagamento AS ppr_cd_periodo
        ,s.[Data] AS DataReferencia
        ,s.[ID_da_Rota] AS ppr_cd_rota
        ,s.[Placa] AS ppr_ds_placa
        ,s.[Tipo_de_Veículo] AS ppr_ds_tipo_veiculo
        ,TRY_CAST(s.[Pacotes] AS INT) AS ppr_qt_pacotes
        ,TRY_CAST(s.[Paradas] AS INT) AS ppr_qt_paradas
        ,GETDATE() AS ppr_dh_criacao
        ,7431 AS ppr_cd_usr_criacao
        ,GETDATE() AS ppr_dh_modificacao
        ,7431 AS ppr_cd_usr_modificacao
        ,1 AS ppr_in_ativo
        ,0 AS ppr_in_excluido
        ,TRY_CAST(REPLACE(REPLACE(LTRIM(RTRIM(REPLACE(s.[Total_a_Pagar],'R$',''))),' ',''),',','') AS DECIMAL(18,2)) AS ppr_vl_total
        ,r.UsuarioDA AS ppr_cd_motorista
        ,m.mot_nm_motorista AS ppr_nome_motorista
        ,s.[Unidade] AS ppr_base_principal
        ,s.[Status_do_Frete] AS ppr_lcto_observacao
        ,s.[ID_do_Driver] AS ppr_driver_id
    INTO #tb_fin_salarios_profissionais
    FROM dbo.tb_stg_ac2_pasta5 s
    INNER JOIN dbo.tb_ml_rotas r
        ON TRY_CAST(s.[ID_da_Rota] AS BIGINT) = r.IdRota
        AND r.IdTransportadora = @IdTransportadora
    LEFT JOIN dbo.tb_motorista m
        ON r.UsuarioDA = m.mot_cd_usuario

    DROP TABLE IF EXISTS #espelho

    SELECT
         ppr_cd_motorista AS mtn_cd_motorista
        ,ppr_nome_motorista AS mtn_nome_motorista
        ,ppr_cd_periodo AS mtn_cd_pgto_periodo
        ,228 AS mtn_cd_status
        ,SUM(ISNULL(ppr_vl_total,0)) AS mtn_vl_nfs
        ,NULL AS mtn_ds_link_nfs
        ,DATEADD(DAY,30,@data_final) AS mtn_dt_prazo_contestacao
        ,GETDATE() AS mtn_dh_criacao
        ,7431 AS mtn_cd_usr_criacao
        ,GETDATE() AS mtn_dh_modificacao
        ,7431 AS mtn_cd_usr_modificacao
        ,0 AS mtn_in_excluido
        ,@clienteid AS mtn_cod_cliente
        ,COUNT(*) AS mtn_qt_rotas
        ,94 AS mtn_cd_tipo_espelho
        ,333 AS mtn_cd_cliente_transportadora
        ,MAX(ppr_base_principal) AS mtn_base_principal
    INTO #espelho
    FROM #tb_fin_salarios_profissionais
    WHERE ppr_nome_motorista IS NOT NULL
    GROUP BY ppr_cd_motorista, ppr_nome_motorista, ppr_cd_periodo

    MERGE tb_pag_espelhos AS target
    USING (
        SELECT
             a.mtn_cd_motorista
            ,a.mtn_cd_pgto_periodo
            ,a.mtn_cd_status
            ,a.mtn_vl_nfs
            ,a.mtn_ds_link_nfs
            ,a.mtn_dt_prazo_contestacao
            ,a.mtn_dh_criacao
            ,a.mtn_cd_usr_criacao
            ,a.mtn_dh_modificacao
            ,a.mtn_cd_usr_modificacao
            ,a.mtn_in_excluido
            ,a.mtn_cod_cliente
            ,a.mtn_qt_rotas
            ,a.mtn_cd_tipo_espelho
            ,a.mtn_cd_cliente_transportadora
            ,a.mtn_base_principal
            ,a.mtn_nome_motorista
            ,1189 AS mtn_cd_operacao
        FROM #espelho a
        WHERE a.mtn_nome_motorista IS NOT NULL
    ) AS source
    ON (
        target.mtn_cd_motorista = source.mtn_cd_motorista
        AND target.mtn_cd_pgto_periodo = source.mtn_cd_pgto_periodo
        AND target.mtn_in_excluido = 0
    )
    WHEN MATCHED THEN
        UPDATE SET
             mtn_vl_nfs = source.mtn_vl_nfs
            ,mtn_dt_prazo_contestacao = source.mtn_dt_prazo_contestacao
            ,mtn_dh_modificacao = source.mtn_dh_modificacao
            ,mtn_cd_usr_modificacao = source.mtn_cd_usr_modificacao
            ,mtn_in_excluido = source.mtn_in_excluido
            ,mtn_cod_cliente = source.mtn_cod_cliente
            ,mtn_qt_rotas = source.mtn_qt_rotas
            ,mtn_cd_tipo_espelho = source.mtn_cd_tipo_espelho
            ,mtn_cd_cliente_transportadora = source.mtn_cd_cliente_transportadora
            ,mtn_base_principal = source.mtn_base_principal
            ,mtn_nome_motorista = source.mtn_nome_motorista
    WHEN NOT MATCHED THEN
        INSERT (
             mtn_cd_motorista
            ,mtn_cd_pgto_periodo
            ,mtn_cd_status
            ,mtn_vl_nfs
            ,mtn_ds_link_nfs
            ,mtn_dt_prazo_contestacao
            ,mtn_dh_criacao
            ,mtn_cd_usr_criacao
            ,mtn_dh_modificacao
            ,mtn_cd_usr_modificacao
            ,mtn_in_excluido
            ,mtn_cod_cliente
            ,mtn_qt_rotas
            ,mtn_cd_tipo_espelho
            ,mtn_cd_cliente_transportadora
            ,mtn_base_principal
            ,mtn_nome_motorista
            ,mtn_cd_operacao
        )
        VALUES (
             source.mtn_cd_motorista
            ,source.mtn_cd_pgto_periodo
            ,source.mtn_cd_status
            ,source.mtn_vl_nfs
            ,source.mtn_ds_link_nfs
            ,source.mtn_dt_prazo_contestacao
            ,source.mtn_dh_criacao
            ,source.mtn_cd_usr_criacao
            ,source.mtn_dh_modificacao
            ,source.mtn_cd_usr_modificacao
            ,source.mtn_in_excluido
            ,source.mtn_cod_cliente
            ,source.mtn_qt_rotas
            ,source.mtn_cd_tipo_espelho
            ,source.mtn_cd_cliente_transportadora
            ,source.mtn_base_principal
            ,source.mtn_nome_motorista
            ,source.mtn_cd_operacao
        );

    MERGE INTO tb_pgto_periodo_rota AS target
    USING (
        SELECT
            a.ppr_cd_periodo
            ,a.ppr_vl_total
            ,a.ppr_cd_usr_criacao
            ,a.ppr_dh_modificacao
            ,a.ppr_cd_usr_modificacao
            ,a.ppr_in_ativo
            ,a.ppr_in_excluido
            ,a.ppr_cd_motorista
            ,b.mtn_cd_motorista_nfs AS ppr_cd_motorista_nfs
            ,TRY_CAST(a.DataReferencia AS DATE) AS ppr_data_referencia
            ,a.ppr_base_principal
            ,'Inteira' AS ppr_tipo_rota
            ,a.ppr_nome_motorista
            ,b.mtn_cd_motorista_nfs AS ppr_cd_pgto_espelho
            ,a.ppr_lcto_observacao
            ,a.ppr_cd_rota
            ,a.ppr_ds_placa
            ,a.ppr_ds_tipo_veiculo
            ,a.ppr_qt_pacotes
            ,a.ppr_qt_paradas
        FROM #tb_fin_salarios_profissionais a
        INNER JOIN tb_pag_espelhos b
            ON a.ppr_cd_periodo = b.mtn_cd_pgto_periodo
            AND a.ppr_nome_motorista = b.mtn_nome_motorista
            AND b.mtn_in_excluido = 0
    ) AS source
    ON target.ppr_cd_periodo = source.ppr_cd_periodo
    AND target.ppr_cd_rota = source.ppr_cd_rota
    AND target.ppr_in_excluido = 0
    AND target.ppr_lcto_cd_lancamento IS NULL
    WHEN MATCHED THEN
        UPDATE SET
             target.ppr_vl_total = source.ppr_vl_total
            ,target.ppr_cd_usr_criacao = source.ppr_cd_usr_criacao
            ,target.ppr_dh_modificacao = source.ppr_dh_modificacao
            ,target.ppr_cd_usr_modificacao = source.ppr_cd_usr_modificacao
            ,target.ppr_in_ativo = source.ppr_in_ativo
            ,target.ppr_in_excluido = source.ppr_in_excluido
            ,target.ppr_cd_motorista = source.ppr_cd_motorista
            ,target.ppr_cd_motorista_nfs = source.ppr_cd_motorista_nfs
            ,target.ppr_data_referencia = source.ppr_data_referencia
            ,target.ppr_base_principal = source.ppr_base_principal
            ,target.ppr_tipo_rota = source.ppr_tipo_rota
            ,target.ppr_nome_motorista = source.ppr_nome_motorista
            ,target.ppr_cd_pgto_espelho = source.ppr_cd_pgto_espelho
            ,target.ppr_lcto_observacao = source.ppr_lcto_observacao
            ,target.ppr_ds_placa = source.ppr_ds_placa
            ,target.ppr_ds_tipo_veiculo = source.ppr_ds_tipo_veiculo
            ,target.ppr_qt_pacotes = source.ppr_qt_pacotes
            ,target.ppr_qt_paradas = source.ppr_qt_paradas
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
             ppr_cd_periodo
            ,ppr_vl_total
            ,ppr_cd_usr_criacao
            ,ppr_dh_modificacao
            ,ppr_cd_usr_modificacao
            ,ppr_in_ativo
            ,ppr_in_excluido
            ,ppr_cd_motorista
            ,ppr_cd_motorista_nfs
            ,ppr_data_referencia
            ,ppr_base_principal
            ,ppr_tipo_rota
            ,ppr_nome_motorista
            ,ppr_cd_pgto_espelho
            ,ppr_lcto_observacao
            ,ppr_cd_rota
            ,ppr_ds_placa
            ,ppr_ds_tipo_veiculo
            ,ppr_qt_pacotes
            ,ppr_qt_paradas
        )
        VALUES (
             source.ppr_cd_periodo
            ,source.ppr_vl_total
            ,source.ppr_cd_usr_criacao
            ,source.ppr_dh_modificacao
            ,source.ppr_cd_usr_modificacao
            ,source.ppr_in_ativo
            ,source.ppr_in_excluido
            ,source.ppr_cd_motorista
            ,source.ppr_cd_motorista_nfs
            ,source.ppr_data_referencia
            ,source.ppr_base_principal
            ,source.ppr_tipo_rota
            ,source.ppr_nome_motorista
            ,source.ppr_cd_pgto_espelho
            ,source.ppr_lcto_observacao
            ,source.ppr_cd_rota
            ,source.ppr_ds_placa
            ,source.ppr_ds_tipo_veiculo
            ,source.ppr_qt_pacotes
            ,source.ppr_qt_paradas
        );

END
 
GO
