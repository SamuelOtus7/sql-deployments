-- ============================================================
-- BASELINE: dbo.UspFinGeraEspelhoLancamentosSemRota
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinGeraEspelhoLancamentosSemRota]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UspFinGeraEspelhoLancamentosSemRota]
(
    @CodPeriodoPagamento VARCHAR(50)                 
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;  

    DECLARE 
        @data_inicial DATE,
        @data_final DATE,
        @clienteid INT,
        @Operacao INT, 
        @usuarioIrisys INT,
        @IdCliTransportadora INT,
        @DataPrevistaPagamento DATE;

    BEGIN TRY
        
        SELECT 
            @data_inicial = pgp_dt_inicio,
            @data_final = pgp_dt_fim,
            @clienteid = pgp_cd_cliente,
            @DataPrevistaPagamento = pgp_dt_prevista_pagamento
        FROM dbo.tb_pgto_periodo WITH (NOLOCK)
        WHERE pgp_cd_periodo = @CodPeriodoPagamento
		and pgp_cd_cliente = 63
		;



        IF @clienteid IS NULL 
        BEGIN
            RETURN 0; 
        END

		SET @usuarioIrisys = 7;

        SET @IdCliTransportadora = (
            SELECT lst_cd_lista 
            FROM tb_lista WITH (NOLOCK)
            WHERE lst_nm_lista = 'Clientes transportadoras'
              AND lst_ds_label = 'Mercado Livre'
              AND lst_cd_cliente = @clienteid
        );

        SET @Operacao = (
            SELECT lst_cd_lista
            FROM tb_lista WITH (NOLOCK)
            WHERE lst_nm_lista = 'Operações Marketplace'
              AND lst_ds_valor = 'LM'
              AND lst_cd_cliente = @clienteid
        );

        BEGIN TRANSACTION;
        
        DROP TABLE IF EXISTS #lancamentos_PF_sem_rota;

		
        SELECT a.* 
        INTO #lancamentos_PF_sem_rota
        FROM vw_lancamentos_manuais_aprovados AS a (NOLOCK)
        LEFT JOIN tb_pag_espelhos AS b (NOLOCK)
            ON a.tlm_cd_cliente = b.mtn_cod_cliente
            AND a.tlm_cd_motorista = b.mtn_nome_motorista
            AND b.mtn_cd_pgto_periodo = @CodPeriodoPagamento 
        WHERE a.plm_nm_tipo IN ('PF - Endereço não visitado', 'PF - Pacote Perdido', 'PF - PNR')
            AND b.mtn_nome_motorista IS NULL 
            AND CAST(a.tlm_dh_referencia AS DATE) BETWEEN @data_inicial AND @data_final
            AND a.tlm_cd_cliente = @clienteid
            AND NOT EXISTS (
                SELECT 1
                FROM vw_rotas AS R (NOLOCK)
                WHERE R.nomemotorista = a.tlm_cd_motorista
                    AND CAST(R.datareferencia AS DATE) BETWEEN @data_inicial AND @data_final
                    AND R.idrota IS NOT NULL
        );

        DROP TABLE IF EXISTS #espelho;

        SELECT 
            DISTINCT 
            LMA.tlm_cd_motorista AS mtn_nome_motorista,
            U.usr_cd_usuario AS mtn_cd_motorista, 
            @CodPeriodoPagamento AS mtn_cd_pgto_periodo,
            228 AS mtn_cd_status, 
            0 AS mtn_vl_nfs,
            NULL AS mtn_ds_link_nfs,
            DATEADD(DAY, 30, @data_final) AS mtn_dt_prazo_contestacao,
            GETDATE() AS mtn_dh_criacao,
            @usuarioIrisys AS mtn_cd_usr_criacao,
            GETDATE() AS mtn_dh_modificacao,
            @usuarioIrisys AS mtn_cd_usr_modificacao,
            0 AS mtn_in_excluido,
            @clienteid AS mtn_cod_cliente, 
            0 AS mtn_qt_rotas, 
            94 AS mtn_cd_tipo_espelho, 
            @IdCliTransportadora AS mtn_cd_cliente_transportadora,
            BASE.bss_cd_base AS mtn_cd_base,
            LMA.tlm_cd_service_center  AS mtn_base_principal,
            @Operacao AS mtn_cd_operacao,
            @DataPrevistaPagamento mtn_dt_prevista_pagamento
        INTO #espelho
        FROM #lancamentos_PF_sem_rota AS LMA WITH (NOLOCK) 
        LEFT JOIN tb_usuario AS U WITH (NOLOCK)
            ON LMA.tlm_cd_motorista = U.usr_nm_usuario
            AND LMA.tlm_cd_cliente = U.cli_cd_codigo_cliente
        LEFT JOIN tb_bases AS BASE (NOLOCK) 
	        ON LMA.tlm_cd_service_center = BASE.bss_ds_sigla and BASE.bss_cd_idtransportadora = 1731064496;

        INSERT INTO [dbo].[tb_pag_espelhos]
           ([mtn_cod_cliente], [mtn_cd_pgto_periodo], [mtn_cd_motorista], [mtn_nome_motorista], 
             [mtn_cd_operacao], [mtn_cd_status], [mtn_dh_criacao], [mtn_cd_usr_criacao], 
             [mtn_dh_modificacao], [mtn_cd_usr_modificacao], [mtn_in_excluido],
            [mtn_base_principal], [mtn_cd_base], [mtn_qt_rotas], [mtn_cd_tipo_espelho], 
            [mtn_cd_cliente_transportadora], [mtn_vl_nfs], [mtn_ds_link_nfs], [mtn_dt_prazo_contestacao],mtn_dt_prevista_pagamento)
        SELECT
            mtn_cod_cliente, mtn_cd_pgto_periodo, mtn_cd_motorista, mtn_nome_motorista,
            mtn_cd_operacao, mtn_cd_status, mtn_dh_criacao, mtn_cd_usr_criacao,
            mtn_dh_modificacao, mtn_cd_usr_modificacao, mtn_in_excluido,
            mtn_base_principal, mtn_cd_base, mtn_qt_rotas, mtn_cd_tipo_espelho,
            mtn_cd_cliente_transportadora, mtn_vl_nfs, mtn_ds_link_nfs, mtn_dt_prazo_contestacao,mtn_dt_prevista_pagamento
        FROM #espelho;

        DROP TABLE IF EXISTS #espelho;

        DROP TABLE IF EXISTS #LancamentosPF;

        SELECT 
            LMA.tlm_cd_lancamento_manual,
	        LMA.tlm_cd_rota AS ppr_cd_rota,
            LMA.tlm_cd_motorista AS ppr_nome_motorista,
            CAST(LMA.tlm_dh_referencia AS DATE) AS ppr_data_referencia,
            LMA.tlm_ds_observacao AS ppr_lcto_observacao,
            (ISNULL(LMA.tlm_vl_valor_adicional, 0) + ISNULL(LMA.tlm_vl_valor_rota, 0) - ISNULL(LMA.tlm_vl_valor_descontos, 0)) AS ppr_vl_lancamentos,
            (ISNULL(LMA.tlm_vl_valor_adicional, 0) + ISNULL(LMA.tlm_vl_valor_rota, 0) - ISNULL(LMA.tlm_vl_valor_descontos, 0)) AS ppr_vl_total,
            @CodPeriodoPagamento AS ppr_cd_periodo,
            esp.mtn_cd_motorista_nfs AS ppr_cd_pgto_espelho,
            esp.mtn_cd_motorista AS ppr_cd_motorista,
            esp.mtn_base_principal AS ppr_cd_service_center
        INTO #LancamentosPF
        FROM #lancamentos_PF_sem_rota AS LMA (NOLOCK)
        INNER JOIN
            tb_pag_espelhos AS esp (NOLOCK) 
            ON esp.mtn_nome_motorista = LMA.tlm_cd_motorista
            AND esp.mtn_cod_cliente = LMA.tlm_cd_cliente
            AND esp.mtn_cd_pgto_periodo = @CodPeriodoPagamento
            AND esp.mtn_cd_operacao = @Operacao
        WHERE
            esp.mtn_cd_status IN (34, 228, 38, 1298) 
	        AND NOT EXISTS ( 
                SELECT 1
                FROM tb_pgto_periodo_rota AS PPR (NOLOCK)
                WHERE PPR.ppr_cd_periodo = @CodPeriodoPagamento
                AND PPR.ppr_lcto_cd_lancamento = LMA.tlm_cd_lancamento_manual
            );

        MERGE INTO tb_pgto_periodo_rota AS Target  
        USING #LancamentosPF AS Source 
        ON Target.ppr_cd_periodo = Source.ppr_cd_periodo
            AND Target.ppr_lcto_cd_lancamento = Source.tlm_cd_lancamento_manual
        WHEN NOT MATCHED BY TARGET THEN  
            INSERT ( ppr_cd_rota, ppr_nome_motorista, ppr_data_referencia, ppr_lcto_observacao, ppr_vl_lancamentos, ppr_vl_total, ppr_cd_periodo, ppr_cd_pgto_espelho  
                    , ppr_dh_criacao, ppr_cd_usr_criacao, ppr_dh_modificacao, ppr_cd_usr_modificacao, ppr_in_ativo, ppr_in_excluido  
                    , ppr_cd_motorista, ppr_cd_motorista_nfs, ppr_lcto_cd_lancamento, ppr_base_principal)  
            VALUES (
                    Source.ppr_cd_rota, 
                    Source.ppr_nome_motorista, 
                    Source.ppr_data_referencia, 
                    Source.ppr_lcto_observacao, 
                    Source.ppr_vl_lancamentos, 
                    Source.ppr_vl_total, 
                    Source.ppr_cd_periodo, 
                    Source.ppr_cd_pgto_espelho, 
                    GETDATE(), 
                    @usuarioIrisys, 
                    GETDATE(), 
                    @usuarioIrisys, 
                    1, 0,  
                    Source.ppr_cd_motorista, 
                    Source.ppr_cd_pgto_espelho, 
                    Source.tlm_cd_lancamento_manual, 
                    Source.ppr_cd_service_center
                    )
        WHEN MATCHED THEN 
            UPDATE SET  
                ppr_vl_lancamentos = Source.ppr_vl_lancamentos  
                ,ppr_vl_total = Source.ppr_vl_total
		        ,ppr_lcto_observacao = Source.ppr_lcto_observacao
                ,ppr_dh_modificacao = GETDATE()
                ,ppr_cd_usr_modificacao = @usuarioIrisys;

        DROP TABLE IF EXISTS #LancamentosPF;
        DROP TABLE IF EXISTS #lancamentos_PF_sem_rota;

        COMMIT TRANSACTION;
        
        RETURN 1; 

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        RETURN 0;

    END CATCH
END
GO
