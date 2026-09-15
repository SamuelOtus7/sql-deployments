-- ============================================================
-- BASELINE: dbo.UspMLReprocessamentoKmLogistics
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLReprocessamentoKmLogistics]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--================================================
-- Autor: Saulo Barros
-- Data de Criação: 11/08/2025
-- Descrição: Gera rotas que precisam processar o Km Logistics
--==================================================
CREATE PROCEDURE [dbo].[UspMLReprocessamentoKmLogistics] (
	@datainicio date
	,@datafim date
	,@idrota int = null
)
as
begin

	insert into tb_dra_reprocessamento 
	select 
		clientes.cli_cd_codigo_cliente as dar_cd_cliente,
		1207 as dar_cd_lista_transportadora, --Fixo Mercado Livre
		1209 as dar_cd_lista_operacao,  --Fixo Last Mile
		rotas.IdRota as dar_cd_rota,
		1212 as dar_cd_list_status,   --Fixo Aguardando
		1218 as dar_cd_lista_acao,   --Ficxo Reprocessar KM
		3 as dar_nr_maximo_tentativas,
		0 as dar_nr_execucoes,
		null as dat_dh_processamento,
		null as dar_ds_erro_message,
		getdate() as dar_dh_criacao,
		dar_cd_pacote
	from 
		tb_ml_rotas as rotas with(nolock)
		join tb_clientes as clientes with(nolock) on rotas.IdTransportadora = clientes.cli_id_logistics
		left join (
			select 
				cast(dac_ds_contexto as int) as IdRota,
				dac_dh_processamento
			from 
				db_Irisys_Json.dbo.tb_dra_coleta with(nolock)
			where
				dac_ds_tipo_coleta = 'REPROCESSAR_KM'
				and cast(replace(replace(dac_ds_contexto_json,'{"data":',''),'}','') as decimal(18,4)) > 0
		 ) as dra on rotas.IdRota = dra.IdRota
		left join (
			select 
				*
			from 
				tb_dra_reprocessamento as fila with(nolock)
				join (
						select 
							max(dar_cd_reprocessamento) as ultimo 
						from 
							tb_dra_reprocessamento 
						group by 
							dar_cd_rota,
							dar_cd_cliente
					) as ultimo on fila.dar_cd_reprocessamento = ultimo.ultimo
		) as fila on rotas.IdRota = fila.dar_cd_rota
		and clientes.cli_cd_codigo_cliente = fila.dar_cd_cliente
	where 
		rotas.Excluido = 0
		and rotas.KmLogistics is null
		and rotas.StatusRota <> 'planned'  
		and isnull(SubStatusRota,'') <> 'cancelled'  
		and DataReferencia between @datainicio and @datafim
		and (rotas.IdRota = @idrota or @idrota is null)
		and (
				dra.IdRota is null  
				or 
				(dra.dac_dh_processamento < rotas.DataAtualizacao and (fila.dar_nr_execucoes < fila.dar_nr_maximo_tentativas or fila.dar_ds_erro_message is null))
			)

end
GO
