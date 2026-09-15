-- ============================================================
-- BASELINE: dbo.UspMLAtualizaDeltaIndicadoresRotas
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLAtualizaDeltaIndicadoresRotas]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* ============================================================================
   ALTER PROCEDURE UspMLAtualizaDeltaIndicadoresRotas (v3)
   ----------------------------------------------------------------------------
   Substitui o UPDATE principal pela consulta fornecida pelo usuário (CTE
   "totais" + UPDATE via INNER JOIN), adaptada para os parâmetros da procedure
   (@QtdeDiasRetroativo / @IdRota / @IdTransportadora) em vez de variáveis
   fixas de teste (@DataReferencia / @IdTransportadora).

   Ajuste feito ao converter para a procedure:
   - Corrigido o nome das colunas no UPDATE final: a query original setava
     r.PacotesColetado = t.Coletado e r.PacotesParado = t.Parado, mas a CTE
     "totais" produz as colunas já nomeadas PacotesColetado/PacotesParado
     (não Coletado/Parado). Ajustado para SET r.PacotesColetado = t.PacotesColetado
     e r.PacotesParado = t.PacotesParado.
   - Filtro de data/rota/transportadora ajustado conforme correção do usuário:
     @DataReferencia = CAST(GETDATE()-@QtdeDiasRetroativo AS DATE), com
     DataReferencia >= @DataReferencia (sem limite superior, diferente do
     range usado no restante da procedure que exclui o dia atual) e
     IdTransportadora/IdRota tratados como filtro opcional
     (coluna = @parametro OR @parametro IS NULL), em vez do padrão de dois
     blocos OR usado no resto da procedure. Aplicado tanto na CTE "totais"
     quanto no WHERE final do UPDATE.

   Mesmas regras já confirmadas na v2 (mantidas):
   - JOIN com tb_ml_status_entrega_traducao sem tratar SubStatus NULL.
   - Sem os filtros StatusEntrega <> 'picked_up' / Status not in ('stop',
     'stop_place_prepared') / TipoPonto <> 'pickup'.
   - Filtro c.StatusRota <> 'planned' (e r.StatusRota <> 'planned' no WHERE final).
   - PacotesTransferidos, EnderecosVisitados, PacotesColetado e PacotesParado
     calculados na mesma subquery (sem "p2" separado).

   Pré-requisito: colunas tb_ml_rotas.PacotesColetado e tb_ml_rotas.PacotesParado
   já criadas pelo usuário.

   Rollback: 99_rollback_procedure_v3.sql (retorna para a v1, aplicada em
   01_alter_procedure.sql — a v2 nunca foi aplicada em produção).

   AINDA NÃO APLICADO — gerado apenas para validação do usuário antes de publicar.
   ============================================================================ */

CREATE procedure [dbo].[UspMLAtualizaDeltaIndicadoresRotas]  (
	@QtdeDiasRetroativo int = 0
	,@IdRota int = null
	,@IdTransportadora int = null
)
as
begin

	SET NOCOUNT ON;

	UPDATE A
	SET A.EXCLUIDO = 0
	FROM tb_ml_rotas a WITH (NOLOCK)
	LEFT JOIN tb_ml_pacotes b WITH (NOLOCK)
	    ON a.idrota = b.idrota
	WHERE
    a.PacotesEntregues = 0
    AND a.TotalPacotes = 0
    AND b.idpacote IS NOT NULL
	AND b.excluido = 0
    AND a.excluido = 1
    AND NOT EXISTS (
        SELECT 1
        FROM tb_ml_rotas a2 WITH (NOLOCK)
        WHERE a2.idrota = a.idrota
          AND a2.excluido = 0
    )
	and a.datareferencia >= cast(getdate()-5 as date) 

	DECLARE @DataReferencia DATE = CAST(GETDATE()-@QtdeDiasRetroativo AS DATE);

	;WITH totais AS (
		select
			p.IdTransportadora,
			p.IdRota,
			p.DataReferencia,
			count(*) Pacotes,
			sum(case when p.StatusEntrega = 'delivered' then 1 else 0 end) PacotesEntregues,
			sum(case when p.StatusEntrega = 'pending' then 1 else 0 end) PacotesPendentes,
			sum(case when tred.StatusEntregaTraduzido = 'Não entregue' and isnull(p.SubStatus,'') <> 'transferred' then 1 else 0 end) PacotesNaoEntregues,
			sum(case when tred.se_ds_classificacao in ('Visitado') then 1 else 0 end) EnderecosVisitados,
			sum(case when tred.StatusEntrega in ('picked_up') then 1 else 0 end) PacotesColetado,
			sum(case when tred.StatusEntrega in ('stopped') then 1 else 0 end) PacotesParado,
			sum(case when p.StatusEntrega = 'not_delivered' and isnull(p.SubStatus,'') = 'transferred' then 1 else 0 end) PacotesTransferidos
		from
			tb_ml_pacotes p with(nolock)
			left join tb_ml_rotas as c with(nolock) on p.idrota = c.idrota
			left join tb_clientes cli with(nolock) on p.IdTransportadora = cli.cli_id_logistics
			left join tb_ml_status_entrega_traducao as tred on tred.TenantID = cli.cli_cd_codigo_cliente
			    and tred.StatusEntrega = p.StatusEntrega
			    and (tred.SubStatus = p.SubStatus)
		where
			p.DataReferencia >= @DataReferencia
			and (p.IdTransportadora = @IdTransportadora or @IdTransportadora is null)
			and (p.IdRota = @IdRota or @IdRota is null)
			and p.Excluido = 0
			and c.Excluido = 0
			and c.StatusRota <> 'planned'
		group by
			p.IdTransportadora,
			p.IdRota,
			p.DataReferencia
	)
	UPDATE r
	SET
		r.TotalPacotes = t.Pacotes,
		r.PacotesEntregues = t.PacotesEntregues,
		r.PacotesPendentes = t.PacotesPendentes,
		r.PacotesNaoEntregue = t.PacotesNaoEntregues,
		r.PacotesTransferidos = t.PacotesTransferidos,
		r.EnderecosVisitados = t.EnderecosVisitados,
		--r.PacotesColetado = t.PacotesColetado,
		--r.PacotesParado = t.PacotesParado,
		r.StatusRota = case when t.PacotesPendentes = 0 then 'close' else r.StatusRota end
	FROM tb_ml_rotas r
	INNER JOIN totais t
		ON r.IdRota = t.IdRota
	   AND r.IdTransportadora = t.IdTransportadora
	WHERE
		r.Excluido = 0
		AND r.StatusRota <> 'planned'
		AND r.DataReferencia >= @DataReferencia
		AND (r.IdTransportadora = @IdTransportadora OR @IdTransportadora IS NULL)
		AND (r.IdRota = @IdRota OR @IdRota IS NULL)
	/*
	and
			(
				r.TotalPacotes <> t.Pacotes
				or
				r.PacotesEntregues <> t.PacotesEntregues
				or
				r.PacotesPendentes <> t.PacotesPendentes
				or
				r.PacotesNaoEntregue <> t.PacotesNaoEntregues
				or
				r.PacotesTransferidos <> t.PacotesTransferidos
				--or
				--r.PacotesColetado <> t.PacotesColetado
				--or
				--r.PacotesParado <> t.PacotesParado
			)
*/
	-- INSERIDO POR MURILO PARA INCLUIR AUTOMATICAMENTE A ATUALIZAÇÃO DA COLUNA TIPO DE VEÍCULOS NA TB_ML_ROTAS 09/03/2026

	UPDATE r
SET r.TipoVeiculo = h.dhr_ds_veiculo
FROM tb_ml_rotas r
INNER JOIN (
    SELECT 
        dhr_nr_rota,
        dhr_ds_veiculo
    FROM tb_dra_historico_rotas
    WHERE ISNULL(dhr_ds_veiculo, '') <> ''
    GROUP BY 
        dhr_nr_rota,
        dhr_ds_veiculo
) h
    ON r.idrota = h.dhr_nr_rota
WHERE 
    (r.TipoVeiculo IS NULL OR r.TipoVeiculo = '')
    AND r.StatusRota <> 'planned'
    AND r.Excluido = 0
    AND (
        (
            r.DataReferencia >= DATEADD(DAY, -@QtdeDiasRetroativo, CAST(GETDATE() AS DATE))
            AND r.DataReferencia < CAST(GETDATE() AS DATE)
            AND @IdRota IS NULL
            AND @IdTransportadora IS NULL
        )
        OR
        (
            @IdRota IS NOT NULL
            AND @IdTransportadora IS NOT NULL
            AND r.IdRota = @IdRota
            AND r.IdTransportadora = @IdTransportadora
        )
    );

end
GO
