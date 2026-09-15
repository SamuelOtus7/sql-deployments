-- ============================================================
-- BASELINE: dbo.SP_gerapagamentosc2_mauais
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[SP_gerapagamentosc2_mauais]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[SP_gerapagamentosc2_mauais] as

declare 
    @CodPeriodoPagamento INT = 3556,
    @CodUsuario INT = 7431

/* === Removidos os DELETEs: nao apaga mais espelhos/rotas do periodo ===
delete from tb_pgto_periodo_rota where ppr_cd_periodo =  @CodPeriodoPagamento
delete from tb_pag_espelhos where mtn_cd_pgto_periodo =  @CodPeriodoPagamento
*/

    DECLARE
          @data_inicial DATE
        , @data_final DATE
        , @clienteid INT
        , @IdCliTransportadora INT
        , @Operacao INT;


        SELECT
              @data_inicial        = pgp_dt_inicio
            , @data_final          = pgp_dt_fim
            , @clienteid           = pgp_cd_cliente
            , @IdCliTransportadora = pgp_cd_cliente_transportadora
            , @Operacao            = pgp_tipo_operacao
        FROM dbo.tb_pgto_periodo WITH (NOLOCK)
        WHERE pgp_cd_periodo = @CodPeriodoPagamento;


        DROP TABLE IF EXISTS #tb_lancamentos_manuais;

        SELECT
              a.tlm_cd_lancamento_manual
            , a.tlm_cd_mot                                  AS ppr_cd_motorista
            , a.tlm_cd_motorista                             AS ppr_nome_motorista
            , CAST(a.tlm_dh_referencia AS DATE)              AS ppr_data_referencia
            , a.tlm_cd_rota                                  AS ppr_cd_rota
            , a.tlm_ds_placa                                 AS ppr_ds_placa
            , a.tlm_cd_service_center                        AS ppr_base_principal
            , a.plm_nm_tipo                                  AS ppr_lcto_tipo
            , a.tlm_ds_observacao                            AS ppr_lcto_observacao
            , ISNULL(a.tlm_vl_lancamento, 0)                 AS ppr_vl_lancamento
        INTO #tb_lancamentos_manuais
        FROM dbo.vw_lancamentos_manuais_aprovados a
        WHERE a.tlm_cd_cliente = @clienteid
          AND a.tlm_cd_cliente_transportadora = @IdCliTransportadora
          AND ISNULL(a.tlm_in_excluido, 0) = 0
          AND a.tlm_cd_mot IS NOT NULL
          AND CAST(a.tlm_dh_referencia AS DATE) BETWEEN @data_inicial AND @data_final
          --and tlm_cd_motorista <> 'Marcus Vinicius Santos Dos Santos';

        DROP TABLE IF EXISTS #espelho;

        SELECT
              ppr_cd_motorista                        AS mtn_cd_motorista
            , ppr_nome_motorista                       AS mtn_nome_motorista
            , @CodPeriodoPagamento                     AS mtn_cd_pgto_periodo
            , 228                                      AS mtn_cd_status
            , SUM(ppr_vl_lancamento)                   AS mtn_vl_nfs
            , NULL                                     AS mtn_ds_link_nfs
            , DATEADD(DAY, 30, @data_final)             AS mtn_dt_prazo_contestacao
            , GETDATE()                                AS mtn_dh_criacao
            , @CodUsuario                              AS mtn_cd_usr_criacao
            , GETDATE()                                AS mtn_dh_modificacao
            , @CodUsuario                              AS mtn_cd_usr_modificacao
            , 0                                        AS mtn_in_excluido
            , @clienteid                               AS mtn_cod_cliente
            , COUNT(*)                                 AS mtn_qt_rotas
            , 94                                       AS mtn_cd_tipo_espelho
            , @IdCliTransportadora                     AS mtn_cd_cliente_transportadora
            , MAX(ppr_base_principal)                  AS mtn_base_principal
        INTO #espelho
        FROM #tb_lancamentos_manuais
        WHERE ppr_nome_motorista IS NOT NULL
        GROUP BY ppr_cd_motorista, ppr_nome_motorista

        /* === MERGE tb_pag_espelhos ===
           ON casa por motorista + periodo + excluido=0 (sem filtro de status).
           WHEN MATCHED AND status IN (32,33) -> atualiza apenas espelhos 32/33.
           WHEN NOT MATCHED -> cria espelho novo (status 228) apenas para
              motoristas que NAO tem nenhum espelho no periodo.
           Isso evita duplicar espelhos para motoristas com status 36/37/39/40. */
        MERGE dbo.tb_pag_espelhos AS target
        USING (
            SELECT
                  e.mtn_cd_motorista
                , e.mtn_cd_pgto_periodo
                , e.mtn_cd_status
                , e.mtn_vl_nfs
                , e.mtn_ds_link_nfs
                , e.mtn_dt_prazo_contestacao
                , e.mtn_dh_criacao
                , e.mtn_cd_usr_criacao
                , e.mtn_dh_modificacao
                , e.mtn_cd_usr_modificacao
                , e.mtn_in_excluido
                , e.mtn_cod_cliente
                , e.mtn_qt_rotas
                , e.mtn_cd_tipo_espelho
                , e.mtn_cd_cliente_transportadora
                , e.mtn_base_principal
                , e.mtn_nome_motorista
                , @Operacao AS mtn_cd_operacao
            FROM #espelho e
        ) AS source
        ON (
            target.mtn_cd_motorista = source.mtn_cd_motorista
            AND target.mtn_cd_pgto_periodo = source.mtn_cd_pgto_periodo
            AND target.mtn_in_excluido = 0
        )
        WHEN MATCHED AND target.mtn_cd_status IN (32, 33) THEN
            UPDATE SET
                  mtn_vl_nfs = source.mtn_vl_nfs
                , mtn_dt_prazo_contestacao = source.mtn_dt_prazo_contestacao
                , mtn_dh_modificacao = source.mtn_dh_modificacao
                , mtn_cd_usr_modificacao = source.mtn_cd_usr_modificacao
                , mtn_nome_motorista = source.mtn_nome_motorista
        WHEN NOT MATCHED THEN
            INSERT (
                  mtn_cd_motorista, mtn_cd_pgto_periodo, mtn_cd_status, mtn_vl_nfs
                , mtn_ds_link_nfs, mtn_dt_prazo_contestacao, mtn_dh_criacao, mtn_cd_usr_criacao
                , mtn_dh_modificacao, mtn_cd_usr_modificacao, mtn_in_excluido, mtn_cod_cliente
                , mtn_qt_rotas, mtn_cd_tipo_espelho, mtn_cd_cliente_transportadora
                , mtn_base_principal, mtn_nome_motorista, mtn_cd_operacao
            )
            VALUES (
                  source.mtn_cd_motorista, source.mtn_cd_pgto_periodo, source.mtn_cd_status, source.mtn_vl_nfs
                , source.mtn_ds_link_nfs, source.mtn_dt_prazo_contestacao, source.mtn_dh_criacao, source.mtn_cd_usr_criacao
                , source.mtn_dh_modificacao, source.mtn_cd_usr_modificacao, source.mtn_in_excluido, source.mtn_cod_cliente
                , source.mtn_qt_rotas, source.mtn_cd_tipo_espelho, source.mtn_cd_cliente_transportadora
                , source.mtn_base_principal, source.mtn_nome_motorista, source.mtn_cd_operacao
            );

        -- Recupera o mtn_cd_motorista_nfs (PK do espelho) para vincular cada lancamento
        DROP TABLE IF EXISTS #lancamentos_com_espelho;

        SELECT
              lm.tlm_cd_lancamento_manual
            , lm.ppr_cd_rota
            , lm.ppr_nome_motorista
            , lm.ppr_data_referencia
            , lm.ppr_ds_placa
            , lm.ppr_base_principal
            , lm.ppr_lcto_tipo
            , lm.ppr_lcto_observacao
            , lm.ppr_vl_lancamento
            , lm.ppr_cd_motorista
            , esp.mtn_cd_motorista_nfs AS ppr_cd_pgto_espelho
        INTO #lancamentos_com_espelho
        FROM #tb_lancamentos_manuais lm
        INNER JOIN dbo.tb_pag_espelhos esp
            ON esp.mtn_cd_motorista = lm.ppr_cd_motorista
            AND esp.mtn_cd_pgto_periodo = @CodPeriodoPagamento
            AND esp.mtn_in_excluido = 0
            and esp.mtn_cd_status IN (32, 33);

        /* === MERGE tb_pgto_periodo_rota ===
           Identifica lancamento existente por ppr_lcto_cd_lancamento = tlm_cd_lancamento_manual.
           MATCHED  -> atualiza o lancamento existente.
           NOT MATCHED -> insere apenas os lancamentos faltantes (sem deletar os demais). */
        MERGE dbo.tb_pgto_periodo_rota AS target
        USING #lancamentos_com_espelho AS source
        ON (
            target.ppr_cd_periodo = @CodPeriodoPagamento
            AND target.ppr_lcto_cd_lancamento = source.tlm_cd_lancamento_manual
        )
        WHEN MATCHED THEN
            UPDATE SET
                  target.ppr_vl_lancamentos = source.ppr_vl_lancamento
                , target.ppr_vl_total = source.ppr_vl_lancamento
                , target.ppr_lcto_observacao = source.ppr_lcto_observacao
                , target.ppr_lcto_tipo = source.ppr_lcto_tipo
                , target.ppr_cd_pgto_espelho = source.ppr_cd_pgto_espelho
                , target.ppr_cd_motorista_nfs = source.ppr_cd_pgto_espelho
                , target.ppr_dh_modificacao = GETDATE()
                , target.ppr_cd_usr_modificacao = @CodUsuario
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (
                  ppr_cd_periodo, ppr_cd_rota, ppr_nome_motorista, ppr_data_referencia
                , ppr_ds_placa, ppr_base_principal, ppr_lcto_tipo, ppr_lcto_observacao
                , ppr_vl_lancamentos, ppr_vl_total, ppr_cd_motorista, ppr_cd_motorista_nfs
                , ppr_cd_pgto_espelho, ppr_lcto_cd_lancamento, ppr_tipo_rota
                , ppr_dh_criacao, ppr_cd_usr_criacao, ppr_dh_modificacao, ppr_cd_usr_modificacao
                , ppr_in_ativo, ppr_in_excluido
            )
            VALUES (
                  @CodPeriodoPagamento, source.ppr_cd_rota, source.ppr_nome_motorista, source.ppr_data_referencia
                , source.ppr_ds_placa, source.ppr_base_principal, source.ppr_lcto_tipo, source.ppr_lcto_observacao
                , source.ppr_vl_lancamento, source.ppr_vl_lancamento, source.ppr_cd_motorista, source.ppr_cd_pgto_espelho
                , source.ppr_cd_pgto_espelho, source.tlm_cd_lancamento_manual, 'Lancamento Manual'
                , GETDATE(), @CodUsuario, GETDATE(), @CodUsuario
                , 1, 0
            );

        DROP TABLE IF EXISTS #lancamentos_com_espelho;
        DROP TABLE IF EXISTS #espelho;
        DROP TABLE IF EXISTS #tb_lancamentos_manuais;
GO
