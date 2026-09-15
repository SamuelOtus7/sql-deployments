/*==============================================================================
  ROLLBACK MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86akezk2w
  Autor        : Devin
  Data         : 2026-09-15
  Descrição    : Reverte dbo.UspMLAtualizaDeltaIndicadoresRotas para a versão
                 anterior sem o ajuste de DataReferencia para rotas fechadas
                 (remove o UPDATE condicionado ao parâmetro
                 'reverter_data_ref_rota_fechada').
  Forward ref  : scripts/forward/2026/09/002_forward_CU-86akezk2w.sql
  Objetos      : dbo.UspMLAtualizaDeltaIndicadoresRotas
  ==============================================================================*/

SET NOCOUNT ON;

/* ============================================================================
   ALTER PROCEDURE UspMLAtualizaDeltaIndicadoresRotas (v4 - rollback de v5)
   ----------------------------------------------------------------------------
   Versão sem o UPDATE de DataReferencia para rotas recém-fechadas.
   ============================================================================ */

BEGIN TRY

	CREATE OR ALTER PROCEDURE [dbo].[UspMLAtualizaDeltaIndicadoresRotas]
		@QtdeDiasRetroativo int = 0
		,@IdRota int = null
		,@IdTransportadora int = null
	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY

			UPDATE A
			SET A.EXCLUIDO = 0
			FROM tb_ml_rotas a WITH (NOLOCK)
			LEFT JOIN tb_ml_pacotes b WITH (NOLOCK) ON a.idrota = b.idrota
			WHERE a.PacotesEntregues = 0
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
			  AND a.datareferencia >= cast(getdate()-5 as date);

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
			SET r.TotalPacotes = t.Pacotes, r.PacotesEntregues = t.PacotesEntregues, r.PacotesPendentes = t.PacotesPendentes, r.PacotesNaoEntregue = t.PacotesNaoEntregues, r.PacotesTransferidos = t.PacotesTransferidos, r.EnderecosVisitados = t.EnderecosVisitados, r.StatusRota = case when t.PacotesPendentes = 0 then 'close' else r.StatusRota end
			FROM tb_ml_rotas r
			INNER JOIN totais t ON r.IdRota = t.IdRota AND r.IdTransportadora = t.IdTransportadora
			WHERE r.Excluido = 0
			  AND r.StatusRota <> 'planned'
			  AND r.DataReferencia >= @DataReferencia
			  AND (r.IdTransportadora = @IdTransportadora OR @IdTransportadora IS NULL)
			  AND (r.IdRota = @IdRota OR @IdRota IS NULL);

			-- INSERIDO POR MURILO PARA INCLUIR AUTOMATICAMENTE A ATUALIZAÇÃO DA COLUNA TIPO DE VEÍCULOS NA TB_ML_ROTAS 09/03/2026

			UPDATE r
			SET r.TipoVeiculo = h.dhr_ds_veiculo
			FROM tb_ml_rotas r
			INNER JOIN (
			    SELECT dhr_nr_rota, dhr_ds_veiculo
			    FROM tb_dra_historico_rotas
			    WHERE ISNULL(dhr_ds_veiculo, '') <> ''
			    GROUP BY dhr_nr_rota, dhr_ds_veiculo
			) h ON r.idrota = h.dhr_nr_rota
			WHERE (r.TipoVeiculo IS NULL OR r.TipoVeiculo = '')
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

		END TRY
		BEGIN CATCH
			THROW;
		END CATCH
	END

	PRINT 'SUCESSO: Rollback de UspMLAtualizaDeltaIndicadoresRotas executado com sucesso.';

END TRY
BEGIN CATCH
	THROW;
END CATCH
