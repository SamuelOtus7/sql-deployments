/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86ak5qxm4
  Autor        : Devin
  Data         : 2026-09-16
  Descrição    : Exclui pacotes com SubStatus = 'transferred' da contagem de
                 TotalPacotes na tb_ml_rotas. Antes, o bloco 'totais' usava
                 count(*), incluindo transferidos no total e novamente na coluna
                 PacotesTransferidos (dupla contagem conceitual).
                 Evidência 2026-09-01 / transportadora 1207810477: 1.260 pacotes
                 transferred inflando TotalPacotes em 73 rotas divergentes.
  Rollback     : scripts/rollback/2026/09/004_rollback_CU-86ak5qxm4.sql
  Objetos      : dbo.UspMLAtualizaDeltaIndicadoresRotas
  Dependências : dbo.tb_ml_rotas, dbo.tb_ml_pacotes, dbo.tb_clientes,
                 dbo.tb_ml_status_entrega_traducao, dbo.tb_dra_historico_rotas,
                 dbo.tb_parametros
  ==============================================================================*/

SET NOCOUNT ON;

/* ============================================================================
   ALTER PROCEDURE UspMLAtualizaDeltaIndicadoresRotas (v7)
   ----------------------------------------------------------------------------
   Mesma versão v6, mas TotalPacotes passa a excluir SubStatus = 'transferred':
     count(*) Pacotes
       ->
     sum(case when isnull(p.SubStatus,'') <> 'transferred' then 1 else 0 end)
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
					sum(case when isnull(p.SubStatus,'') <> 'transferred' then 1 else 0 end) Pacotes,
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

			-- Ajusta DataReferencia das rotas recém-fechadas para a data de início da rota
			-- Só executa quando o parâmetro 'reverter_data_ref_rota_fechada' = 'true' está ativo para o cliente
			-- Não filtra p.DataReferencia = r.DataReferencia: o pacote carrega a data de início,
			-- enquanto a rota fechada pode ter DataReferencia do dia do fechamento
			UPDATE r
			SET DataReferencia = ISNULL(r.DataInicioRota, CAST(r.DataHoraInicio AS DATE))
			FROM tb_ml_rotas r
			WHERE r.StatusRota = 'close'
			  AND r.Excluido = 0
			  AND r.DataReferencia <> ISNULL(r.DataInicioRota, CAST(r.DataHoraInicio AS DATE))
			  AND r.DataReferencia >= @DataReferencia
			  AND (r.IdTransportadora = @IdTransportadora OR @IdTransportadora IS NULL)
			  AND (r.IdRota = @IdRota OR @IdRota IS NULL)
			  AND EXISTS (
			      SELECT 1
			      FROM tb_ml_pacotes p
			      WHERE p.IdRota = r.IdRota
			        AND p.IdTransportadora = r.IdTransportadora
			        AND p.Excluido = 0
			        AND p.StatusEntrega <> 'pending'
			        AND CAST(p.DataHoraEntrega AS DATE) <= DATEADD(DAY, 1, @DataReferencia)
			  )
			  AND EXISTS (
			      SELECT 1
			      FROM tb_clientes cli
			      INNER JOIN tb_parametros prm
			          ON prm.prm_cod_cliente = cli.cli_cd_codigo_cliente
			      WHERE cli.cli_id_logistics = r.IdTransportadora
			        AND prm.prm_ds_chave = 'reverter_data_ref_rota_fechada'
			        AND prm.prm_in_ativo = 1
			        AND prm.prm_in_excluido = 0
			        AND prm.prm_ds_valor = 'true'
			  );

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

	PRINT 'SUCESSO: UspMLAtualizaDeltaIndicadoresRotas alterada com sucesso.';

END TRY
BEGIN CATCH
	THROW;
END CATCH
