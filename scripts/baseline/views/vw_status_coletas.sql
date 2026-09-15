-- ============================================================
-- BASELINE: dbo.vw_status_coletas
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_status_coletas]    Script Date: 14/09/2026 12:12:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vw_status_coletas]
as
select top 50000
	   'Totalizadores' as tipo,
	   cmt_cd_servicecenter as ServiceCenter,
	   COUNT(*) as Coletas,
	   MAX(cmt_dh_escrita) as UltimaColeta,
	   MIN(cmt_dh_escrita) as PrimeiraColeta   ,
	   case when DATEDIFF(second, MIN(cmt_dh_escrita), MAX(cmt_dh_escrita)) > 0 
			then CAST(COUNT(*) as float) / CAST(DATEDIFF(second, MIN(cmt_dh_escrita), MAX(cmt_dh_escrita)) as float)
	   end * 60.0 as ColetasPorMinuto,
	   convert(varchar,dateadd(second,DATEDIFF(SECOND,MAX(cmt_dh_escrita),GETDATE()),0),108) as TempoDesdeAUltimaColeta,
	   DATEDIFF(SECOND,MAX(cmt_dh_escrita),GETDATE()) as SegundosDesdeAUltimaColeta
from db_Irisys_Json.dbo.tb_ml_coleta_totalizador (nolock)
where cast(cmt_dh_referencia as date) = CAST(getdate() as date)
group by cmt_cd_servicecenter

union all

select top 50000
	   'Rotas' as tipo,
	   cmr_cd_rota as IdRota,
	   COUNT(*) as Coletas,
	   MAX(cmr_dh_escrita) as UltimaColeta,
	   MIN(cmr_dh_escrita) as PrimeiraColeta   ,
	   case when DATEDIFF(second, MIN(cmr_dh_escrita), MAX(cmr_dh_escrita)) > 0 
			then CAST(COUNT(*) as float) / CAST(DATEDIFF(second, MIN(cmr_dh_escrita), MAX(cmr_dh_escrita)) as float) * 60.0
	   else 1 end as ColetasPorMinuto,
	   convert(varchar,dateadd(second,DATEDIFF(SECOND,MAX(cmr_dh_escrita),GETDATE()),0),108) as TempoDesdeAUltimaColeta,
	   DATEDIFF(SECOND,MAX(cmr_dh_escrita),GETDATE()) as SegundosDesdeAUltimaColeta
from db_Irisys_Json.dbo.tb_ml_coleta_rotas (nolock)
where cast(cmr_dh_referencia as date)= CAST(getdate() as date)
group by cmr_cd_rota
order by tipo,TempoDesdeAUltimaColeta desc

GO
/****** Object:  Index [idx_DimData_1]    Script Date: 14/09/2026 12:12:56 ******/
CREATE NONCLUSTERED INDEX [idx_DimData_1] ON [dbo].[DimData]
(
	[Data] ASC
)
INCLUDE([DiaDaSemana],[Quinzena],[Mes],[MesAbreviado],[NumMes],[MesAno],[Ano],[Feriado]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [IX_tb_clientes_cli_cd_codigo_cliente]    Script Date: 14/09/2026 12:12:56 ******/
CREATE NONCLUSTERED INDEX [IX_tb_clientes_cli_cd_codigo_cliente] ON [dbo].[override_tb_envio_relatios]
(
	[tb_clientes_cli_cd_codigo_cliente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tb_relatorios_rel_cd_relatorio]    Script Date: 14/09/2026 12:12:56 ******/
CREATE NONCLUSTERED INDEX [IX_tb_relatorios_rel_cd_relatorio] ON [dbo].[override_tb_envio_relatios]
(
	[tb_relatorios_rel_cd_relatorio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_stg_rotas_lh_csv_arquivo]    Script Date: 14/09/2026 12:12:56 ******/
CREATE NONCLUSTERED INDEX [IX_stg_rotas_lh_csv_arquivo] ON [dbo].[stg_rotas_lh_csv]
(
	[nm_arquivo] ASC,
	[dh_carga] ASC
)
INCLUDE([id_rota],[rostering_id],[codigo_rota],[fecha_servicio]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_stg_rotas_lh_csv_rota]    Script Date: 14/09/2026 12:12:56 ******/
CREATE NONCLUSTERED INDEX [IX_stg_rotas_lh_csv_rota] ON [dbo].[stg_rotas_lh_csv]
(
	[id_rota] ASC,
	[rostering_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_action_1]    Script Date: 14/09/2026 12:12:56 ******/
CREATE NONCLUSTERED INDEX [idx_action_1] ON [dbo].[tb_action]
(
	[act_cd_action] ASC,
	[act_nm_action] ASC
)
WHERE ([act_in_ativo]=(1))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [idx_action_controller_1]    Script Date: 14/09/2026 12:12:57 ******/
CREATE NONCLUSTERED INDEX [idx_action_controller_1] ON [dbo].[tb_action_controller]
(
	[acc_cd_action_controller] ASC,
	[acc_cd_action] ASC,
	[acc_cd_controller] ASC
)
WHERE ([acc_in_ativo]=(1))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [idx_action_grupo_acesso_1]    Script Date: 14/09/2026 12:12:57 ******/
CREATE NONCLUSTERED INDEX [idx_action_grupo_acesso_1] ON [dbo].[tb_action_grupo_acesso]
(
	[aga_cd_grupo_acesso] ASC,
	[aga_cd_action_controller] ASC
)
WHERE ([aga_in_ativo]=(1))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [IX_Alarmes_IdGrupo]    Script Date: 14/09/2026 12:12:58 ******/
CREATE NONCLUSTERED INDEX [IX_Alarmes_IdGrupo] ON [dbo].[tb_alarmes]
(
	[IdGrupo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Alarmes_Nome_Ordem]    Script Date: 14/09/2026 12:12:58 ******/
CREATE NONCLUSTERED INDEX [IX_Alarmes_Nome_Ordem] ON [dbo].[tb_alarmes]
(
	[Nome] ASC,
	[Ordem] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF
GO
/****** Object:  Index [idx_apontamento_geo]    Script Date: 14/09/2026 12:12:58 ******/
CREATE NONCLUSTERED INDEX [idx_apontamento_geo] ON [dbo].[tb_apontamento_geo]
(
	[DataReferencia] ASC,
	[apg_cd_transportadora] ASC,
	[apg_cd_motorista] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_apontamento_geo_1]    Script Date: 14/09/2026 12:12:59 ******/
CREATE NONCLUSTERED INDEX [idx_apontamento_geo_1] ON [dbo].[tb_apontamento_geo]
(
	[apg_cd_motorista] ASC
)
INCLUDE([apg_dh_apontamento],[apg_latitude],[apg_longitude],[apg_dh_escrita]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [idx_pedagio1]    Script Date: 14/09/2026 12:12:59 ******/
CREATE NONCLUSTERED INDEX [idx_pedagio1] ON [dbo].[tb_atm_pedagios]
(
	[atp_cd_codigo_cliente] ASC,
	[atp_in_excluido] ASC,
	[atp_cd_codigo_status] ASC,
	[atp_dh_criacao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_tb_atm_pedagios_01]    Script Date: 14/09/2026 12:12:59 ******/
CREATE NONCLUSTERED INDEX [idx_tb_atm_pedagios_01] ON [dbo].[tb_atm_pedagios]
(
	[atp_cd_codigo_cliente] ASC,
	[atp_in_excluido] ASC,
	[atp_cd_codigo_status] ASC
)
INCLUDE([atp_ds_rota],[atp_dc_valor]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_base1]    Script Date: 14/09/2026 12:12:59 ******/
CREATE NONCLUSTERED INDEX [idx_base1] ON [dbo].[tb_bases]
(
	[bss_in_excluido] ASC,
	[bss_cod_cliente] ASC,
	[bss_ds_nome] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_base2]    Script Date: 14/09/2026 12:12:59 ******/
CREATE NONCLUSTERED INDEX [idx_base2] ON [dbo].[tb_bases]
(
	[bss_cd_base] ASC,
	[bss_cod_cliente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_base3]    Script Date: 14/09/2026 12:12:59 ******/
CREATE NONCLUSTERED INDEX [idx_base3] ON [dbo].[tb_bases]
(
	[bss_in_excluido] ASC,
	[bss_cod_cliente] ASC,
	[bss_ds_marketplace] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_bss_ds_marketplace_bss_in_status_bss_in_excluido]    Script Date: 14/09/2026 12:12:59 ******/
CREATE NONCLUSTERED INDEX [IDX_bss_ds_marketplace_bss_in_status_bss_in_excluido] ON [dbo].[tb_bases]
(
	[bss_ds_marketplace] ASC,
	[bss_in_status] ASC,
	[bss_in_excluido] ASC
)
INCLUDE([bss_cd_idtransportadora],[bss_ds_sigla],[bss_ds_nome],[bss_ds_regiao],[bss_ds_cidade],[bss_ds_estado],[bss_dc_latitude],[bss_dc_longitude],[bss_in_xpt],[bss_origem_base],[bss_in_ambulancia]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_base_permission1]    Script Date: 14/09/2026 12:12:59 ******/
CREATE NONCLUSTERED INDEX [idx_base_permission1] ON [dbo].[tb_bases_permissoes]
(
	[bsp_cd_base] ASC,
	[bsp_cod_cliente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_base_permission2]    Script Date: 14/09/2026 12:12:59 ******/
CREATE NONCLUSTERED INDEX [idx_base_permission2] ON [dbo].[tb_bases_permissoes]
(
	[bsp_cd_base] ASC,
	[bsp_cod_cliente] ASC,
	[bsp_cd_usuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UX_tb_classificacao_tributaria_ibscbs_Codigo_Vigencia]    Script Date: 14/09/2026 12:12:59 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UX_tb_classificacao_tributaria_ibscbs_Codigo_Vigencia] ON [dbo].[tb_classificacao_tributaria_ibscbs]
(
	[Codigo] ASC,
	[Dth_VigenciaInicial] ASC
)
WHERE ([Excluido]=(0))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_cliente1]    Script Date: 14/09/2026 12:12:59 ******/
CREATE NONCLUSTERED INDEX [idx_cliente1] ON [dbo].[tb_clientes]
(
	[cli_in_ativo] ASC,
	[cli_cd_codigo_cliente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_cliente2]    Script Date: 14/09/2026 12:12:59 ******/
CREATE NONCLUSTERED INDEX [idx_cliente2] ON [dbo].[tb_clientes]
(
	[cli_id_logistics] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_clientes_access]    Script Date: 14/09/2026 12:12:59 ******/
CREATE NONCLUSTERED INDEX [idx_clientes_access] ON [dbo].[tb_clientes]
(
	[cli_cd_codigo_cliente] ASC
)
INCLUDE([cli_id_logistics],[cli_id_shopee]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [idx_clientes_id_logistics]    Script Date: 14/09/2026 12:13:00 ******/
CREATE UNIQUE NONCLUSTERED INDEX [idx_clientes_id_logistics] ON [dbo].[tb_clientes]
(
	[cli_id_logistics] ASC
)
WHERE ([cli_id_logistics]>(0) AND [cli_cd_codigo_cliente]<>(7))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_tb_clientes]    Script Date: 14/09/2026 12:13:00 ******/
CREATE NONCLUSTERED INDEX [idx_tb_clientes] ON [dbo].[tb_clientes]
(
	[cli_cd_codigo_cliente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_unique_shopee]    Script Date: 14/09/2026 12:13:00 ******/
CREATE UNIQUE NONCLUSTERED INDEX [idx_unique_shopee] ON [dbo].[tb_clientes]
(
	[cli_id_shopee] ASC
)
WHERE ([cli_id_shopee]<>(0))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tb_comprovante_enviado_historico_cod_comprovante_enviado]    Script Date: 14/09/2026 12:13:00 ******/
CREATE NONCLUSTERED INDEX [IX_tb_comprovante_enviado_historico_cod_comprovante_enviado] ON [dbo].[tb_comprovante_enviado_historico]
(
	[ceh_cd_comprovante_enviado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_uk_comprovantes_pix_gr]    Script Date: 14/09/2026 12:13:00 ******/
CREATE UNIQUE NONCLUSTERED INDEX [idx_uk_comprovantes_pix_gr] ON [dbo].[tb_comprovantes]
(
	[cmp_cd_cliente] ASC
)
WHERE ([cmp_in_pix_gr]=(1) AND [cmp_in_ativo]=(1) AND [cmp_in_excluido]=(0))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_ComprovantesEnviados_Usuario_Cliente_Ativo_Excluido]    Script Date: 14/09/2026 12:13:00 ******/
CREATE NONCLUSTERED INDEX [IX_ComprovantesEnviados_Usuario_Cliente_Ativo_Excluido] ON [dbo].[tb_comprovantes_enviados]
(
	[cme_cd_usuario] ASC,
	[cme_cd_cliente] ASC,
	[cme_in_ativo] ASC,
	[cme_in_excluido] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_ContratosDocumentosEnviados_Usuario_Cliente_Ativo_Excluido]    Script Date: 14/09/2026 12:13:00 ******/
CREATE NONCLUSTERED INDEX [IX_ContratosDocumentosEnviados_Usuario_Cliente_Ativo_Excluido] ON [dbo].[tb_contratos_documentos_enviados]
(
	[cde_cd_usuario] ASC,
	[cde_cd_cliente] ASC,
	[cde_in_ativo] ASC,
	[cde_in_excluido] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_controller_2]    Script Date: 14/09/2026 12:13:00 ******/
CREATE NONCLUSTERED INDEX [idx_controller_2] ON [dbo].[tb_controller]
(
	[ctr_cd_controller] ASC,
	[ctr_ds_modulo] ASC,
	[ctr_nm_controller] ASC
)
WHERE ([ctr_in_ativo]=(1))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_controller_3]    Script Date: 14/09/2026 12:13:00 ******/
CREATE NONCLUSTERED INDEX [idx_controller_3] ON [dbo].[tb_controller]
(
	[ctr_nm_controller] ASC
)
WHERE ([ctr_in_system]=(1))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_tb_controller_1]    Script Date: 14/09/2026 12:13:01 ******/
CREATE NONCLUSTERED INDEX [idx_tb_controller_1] ON [dbo].[tb_controller]
(
	[ctr_nm_controller] ASC
)
WHERE ([ctr_in_system]=(1))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_tb_cte_log_Etapa]    Script Date: 14/09/2026 12:13:01 ******/
CREATE NONCLUSTERED INDEX [IX_tb_cte_log_Etapa] ON [dbo].[tb_cte_log]
(
	[Etapa] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tb_cte_log_IdLote_DataCriacao]    Script Date: 14/09/2026 12:13:01 ******/
CREATE NONCLUSTERED INDEX [IX_tb_cte_log_IdLote_DataCriacao] ON [dbo].[tb_cte_log]
(
	[IdLote] ASC,
	[DataCriacao] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tb_cte_log_ItemId]    Script Date: 14/09/2026 12:13:01 ******/
CREATE NONCLUSTERED INDEX [IX_tb_cte_log_ItemId] ON [dbo].[tb_cte_log]
(
	[ItemId] ASC
)
WHERE ([ItemId] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_tb_cte_log_Nivel_DataCriacao]    Script Date: 14/09/2026 12:13:01 ******/
CREATE NONCLUSTERED INDEX [IX_tb_cte_log_Nivel_DataCriacao] ON [dbo].[tb_cte_log]
(
	[Nivel] ASC,
	[DataCriacao] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tb_cte_log_TenantId_IdLote]    Script Date: 14/09/2026 12:13:01 ******/
CREATE NONCLUSTERED INDEX [IX_tb_cte_log_TenantId_IdLote] ON [dbo].[tb_cte_log]
(
	[TenantId] ASC,
	[IdLote] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [NonClusteredIndex-20250802-002259]    Script Date: 14/09/2026 12:13:01 ******/
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20250802-002259] ON [dbo].[tb_cte_lotes_pacotes]
(
	[clp_cd_cte_item] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tb_cte_regra_ibscbs_Tenant_Vigencia]    Script Date: 14/09/2026 12:13:01 ******/
CREATE NONCLUSTERED INDEX [IX_tb_cte_regra_ibscbs_Tenant_Vigencia] ON [dbo].[tb_cte_regra_ibscbs]
(
	[TenantId] ASC,
	[Dth_VigenciaInicial] ASC,
	[Dth_VigenciaFinal] ASC
)
WHERE ([Excluido]=(0))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_CidadesGeo_DsCidade_Null]    Script Date: 14/09/2026 12:13:01 ******/
CREATE NONCLUSTERED INDEX [IDX_CidadesGeo_DsCidade_Null] ON [dbo].[tb_dra_cidades_geo]
(
	[dcg_cidade_distante] DESC,
	[dcg_cd_cidade_gei] ASC
)
WHERE ([dcg_ds_cidade] IS NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_dcg_ds_cidade]    Script Date: 14/09/2026 12:13:01 ******/
CREATE NONCLUSTERED INDEX [IDX_dcg_ds_cidade] ON [dbo].[tb_dra_cidades_geo]
(
	[dcg_ds_cidade] ASC
)
INCLUDE([dcg_nr_latitude],[dcg_nr_longitude]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [idx_dra_cidades_geo]    Script Date: 14/09/2026 12:13:02 ******/
CREATE NONCLUSTERED INDEX [idx_dra_cidades_geo] ON [dbo].[tb_dra_cidades_geo]
(
	[dcg_cd_cidade_gei] ASC
)
INCLUDE([dcg_nr_latitude],[dcg_nr_longitude],[dcg_ds_cidade],[dcg_nr_cep],[dcg_ds_estado],[dcg_distrito]) 
WHERE ([dcg_ds_cidade] IS NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_dam_cd_transportadora_dam_cd_rota]    Script Date: 14/09/2026 12:13:02 ******/
CREATE NONCLUSTERED INDEX [IDX_dam_cd_transportadora_dam_cd_rota] ON [dbo].[tb_dra_coleta_maps]
(
	[dam_cd_transportadora] ASC,
	[dam_cd_rota] ASC
)
INCLUDE([dam_dh_coleta]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_dra_coleta_maps_1]    Script Date: 14/09/2026 12:13:03 ******/
CREATE NONCLUSTERED INDEX [idx_dra_coleta_maps_1] ON [dbo].[tb_dra_coleta_maps]
(
	[dam_nm_origem] ASC,
	[dam_cd_marketplace] ASC,
	[dam_dh_referencia] ASC
)
INCLUDE([dam_cd_transportadora],[dam_cd_rota]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_dra_coleta_maps_2]    Script Date: 14/09/2026 12:13:03 ******/
CREATE NONCLUSTERED INDEX [idx_dra_coleta_maps_2] ON [dbo].[tb_dra_coleta_maps]
(
	[dam_nm_origem] ASC,
	[dam_dh_referencia] ASC
)
INCLUDE([dam_cd_transportadora],[dam_cd_rota]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [idx_dra_coleta_maps_3]    Script Date: 14/09/2026 12:13:04 ******/
CREATE NONCLUSTERED INDEX [idx_dra_coleta_maps_3] ON [dbo].[tb_dra_coleta_maps]
(
	[dam_in_processado] ASC
)
INCLUDE([dam_ds_km]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [idx_dra_coleta_maps_4]    Script Date: 14/09/2026 12:13:04 ******/
CREATE NONCLUSTERED INDEX [idx_dra_coleta_maps_4] ON [dbo].[tb_dra_coleta_maps]
(
	[dam_in_processado] ASC
)
INCLUDE([dam_ds_km],[dam_vl_km]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_dra_erros_coleta_1]    Script Date: 14/09/2026 12:13:05 ******/
CREATE NONCLUSTERED INDEX [idx_dra_erros_coleta_1] ON [dbo].[tb_dra_erros_coleta]
(
	[dec_ds_tipo_coleta] ASC
)
INCLUDE([dec_cd_transportadora],[dec_ds_contexto]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_dra_erros_coleta_2]    Script Date: 14/09/2026 12:13:05 ******/
CREATE NONCLUSTERED INDEX [idx_dra_erros_coleta_2] ON [dbo].[tb_dra_erros_coleta]
(
	[dec_ds_tipo_coleta] ASC
)
INCLUDE([dec_cd_transportadora],[dec_ds_contexto],[dec_ds_erro],[dec_dh_coleta]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_dra_erros_coleta_3]    Script Date: 14/09/2026 12:13:06 ******/
CREATE NONCLUSTERED INDEX [idx_dra_erros_coleta_3] ON [dbo].[tb_dra_erros_coleta]
(
	[dec_ds_tipo_coleta] ASC,
	[dec_ds_erro] ASC,
	[dec_nr_tentativas] ASC
)
INCLUDE([dec_ds_contexto],[dec_dt_referencia],[dec_dh_escrita]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_dra_erros_coleta01]    Script Date: 14/09/2026 12:13:06 ******/
CREATE NONCLUSTERED INDEX [idx_dra_erros_coleta01] ON [dbo].[tb_dra_erros_coleta]
(
	[dec_ds_tipo_coleta] ASC,
	[dec_ds_erro] ASC,
	[dec_nr_tentativas] ASC
)
INCLUDE([dec_ds_contexto]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_dra_historico_rotas_cli_data_rota]    Script Date: 14/09/2026 12:13:06 ******/
CREATE NONCLUSTERED INDEX [IX_dra_historico_rotas_cli_data_rota] ON [dbo].[tb_dra_historico_rotas]
(
	[dhr_cd_cliente] ASC,
	[dhr_dt_data] ASC,
	[dhr_nr_rota] ASC
)
INCLUDE([dhr_vl_quilometros_percorridos]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tb_dra_historico_rotas_lh_dh_coleta]    Script Date: 14/09/2026 12:13:06 ******/
CREATE NONCLUSTERED INDEX [IX_tb_dra_historico_rotas_lh_dh_coleta] ON [dbo].[tb_dra_historico_rotas_lh]
(
	[dhl_dh_coleta] DESC
)
INCLUDE([dhl_cd_cliente],[dhl_nr_route_id]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tb_dra_historico_rotas_lh_dt_servico]    Script Date: 14/09/2026 12:13:06 ******/
CREATE NONCLUSTERED INDEX [IX_tb_dra_historico_rotas_lh_dt_servico] ON [dbo].[tb_dra_historico_rotas_lh]
(
	[dhl_cd_cliente] ASC,
	[dhl_dt_servico] ASC
)
INCLUDE([dhl_nr_route_id],[dhl_ds_estado],[dhl_ds_substatus]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_dra_reprocessamento_FILA]    Script Date: 14/09/2026 12:13:06 ******/
CREATE NONCLUSTERED INDEX [IDX_dra_reprocessamento_FILA] ON [dbo].[tb_dra_reprocessamento]
(
	[dar_cd_lista_status] ASC,
	[dar_cd_lista_operacao] ASC,
	[dar_cd_lista_acao] ASC,
	[dar_dh_criacao] DESC,
	[dar_nr_execucoes] ASC
)
INCLUDE([dar_nr_maximo_tentativas],[dar_cd_cliente]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [NonClusteredIndex-20251216-212322]    Script Date: 14/09/2026 12:13:06 ******/
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20251216-212322] ON [dbo].[tb_dra_reprocessamento]
(
	[dar_cd_lista_status] ASC,
	[dar_cd_lista_acao] ASC,
	[dar_cd_lista_operacao] ASC,
	[dar_nr_maximo_tentativas] ASC,
	[dar_nr_execucoes] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [ix_envio_boas_vindas_lote_cliente]    Script Date: 14/09/2026 12:13:06 ******/
CREATE NONCLUSTERED INDEX [ix_envio_boas_vindas_lote_cliente] ON [dbo].[tb_envio_boas_vindas_lote]
(
	[evl_cd_cliente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ix_envio_boas_vindas_det_lote_status]    Script Date: 14/09/2026 12:13:06 ******/
CREATE NONCLUSTERED INDEX [ix_envio_boas_vindas_det_lote_status] ON [dbo].[tb_envio_boas_vindas_lote_detalhe]
(
	[evld_cd_lote] ASC,
	[evld_ds_status] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ix_envio_boas_vindas_det_status]    Script Date: 14/09/2026 12:13:06 ******/
CREATE NONCLUSTERED INDEX [ix_envio_boas_vindas_det_status] ON [dbo].[tb_envio_boas_vindas_lote_detalhe]
(
	[evld_ds_status] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [NonClusteredIndex-20241112-125310]    Script Date: 14/09/2026 12:13:06 ******/
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20241112-125310] ON [dbo].[tb_escala_motorista]
(
	[em_cd_base] ASC,
	[em_cd_cliente] ASC,
	[em_data_referencia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_tb_fat_aprovacao_motorista_01]    Script Date: 14/09/2026 12:13:06 ******/
CREATE NONCLUSTERED INDEX [idx_tb_fat_aprovacao_motorista_01] ON [dbo].[tb_fat_aprovacao_motorista]
(
	[fam_cd_cliente] ASC,
	[fam_cd_usuario_motorista] ASC,
	[fam_dt_data] ASC
)
INCLUDE([fam_ds_rota],[fam_ds_entregas],[fam_ds_km],[fam_ds_valor],[fam_ds_sucesso],[fam_ds_insucesso],[fam_ds_url_maps],[fam_ds_status],[fam_cd_usuario_criacao],[fam_dh_criacao],[fam_cd_usuario_modificacao],[fam_dh_modificacao],[fam_dh_aprovacao],[fam_cd_usuario_aprovacao],[fam_in_excluido],[fam_ds_km_excedente]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_datacadastro]    Script Date: 14/09/2026 12:13:06 ******/
CREATE NONCLUSTERED INDEX [idx_datacadastro] ON [dbo].[tb_faturamento_pendente_processamento]
(
	[DataCadastro] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_marketplace]    Script Date: 14/09/2026 12:13:06 ******/
CREATE NONCLUSTERED INDEX [idx_marketplace] ON [dbo].[tb_faturamento_pendente_processamento]
(
	[CodMarketplace] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_periodo]    Script Date: 14/09/2026 12:13:06 ******/
CREATE NONCLUSTERED INDEX [idx_periodo] ON [dbo].[tb_faturamento_pendente_processamento]
(
	[Ano] ASC,
	[Mes] ASC,
	[Quinzena] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_status]    Script Date: 14/09/2026 12:13:06 ******/
CREATE NONCLUSTERED INDEX [idx_status] ON [dbo].[tb_faturamento_pendente_processamento]
(
	[Status] ASC
)
INCLUDE([Ano],[Mes],[Quinzena],[CodMarketplace],[LinkArquivo]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_status_ano_mes]    Script Date: 14/09/2026 12:13:06 ******/
CREATE NONCLUSTERED INDEX [idx_status_ano_mes] ON [dbo].[tb_faturamento_pendente_processamento]
(
	[Status] ASC,
	[Ano] ASC,
	[Mes] ASC,
	[Quinzena] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_base_frete_adiciona1]    Script Date: 14/09/2026 12:13:06 ******/
CREATE NONCLUSTERED INDEX [idx_base_frete_adiciona1] ON [dbo].[tb_fin_base_frete_adicional]
(
	[bfa_cd_transportadora] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_bfm_cd_transportadora_bfm_vl_inicio_faixa]    Script Date: 14/09/2026 12:13:06 ******/
CREATE NONCLUSTERED INDEX [idx_bfm_cd_transportadora_bfm_vl_inicio_faixa] ON [dbo].[tb_fin_base_frete_motorista]
(
	[bfm_cd_transportadora] ASC,
	[bfm_vl_inicio_faixa] ASC
)
INCLUDE([bfm_cd_service_center],[bfm_cd_tipo_veiculo],[bfm_vl_fim_faixa],[bfm_cd_codigo_cliente]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_tb_fin_base_frete_motorista_cidade]    Script Date: 14/09/2026 12:13:06 ******/
CREATE NONCLUSTERED INDEX [idx_tb_fin_base_frete_motorista_cidade] ON [dbo].[tb_fin_base_frete_motorista]
(
	[bfm_cd_transportadora] ASC,
	[bfm_cd_service_center] ASC,
	[bfm_nm_cidade] ASC
)
INCLUDE([bfm_cd_tipo_veiculo],[bfm_vl_inicio_faixa],[bfm_vl_fim_faixa],[bfm_vl_frete],[bfm_vl_frete_pm],[bfm_vl_frete_fixo],[bmf_cd_tipo_contrato],[bfm_cd_codigo_cliente],[bfm_vl_domfer_am],[bfm_vl_domfer_pm],[bfm_data_inicio_vigencia],[bfm_data_fim_vigencia],[bfm_nm_regiao],[bfm_cd_operacao],[ValidFrom],[ValidTo]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_tb_fin_base_frete_motorista_operacao]    Script Date: 14/09/2026 12:13:06 ******/
CREATE NONCLUSTERED INDEX [idx_tb_fin_base_frete_motorista_operacao] ON [dbo].[tb_fin_base_frete_motorista]
(
	[bfm_cd_operacao] ASC
)
INCLUDE([bfm_cd_transportadora],[bfm_cd_service_center],[bfm_nm_cidade],[bfm_cd_tipo_veiculo],[bfm_vl_inicio_faixa],[bfm_vl_fim_faixa],[bfm_vl_frete],[bfm_vl_frete_pm],[bfm_vl_frete_fixo],[bmf_cd_tipo_contrato],[bfm_cd_codigo_cliente],[bfm_vl_domfer_am],[bfm_vl_domfer_pm],[bfm_data_inicio_vigencia],[bfm_data_fim_vigencia],[bfm_nm_regiao],[ValidFrom],[ValidTo]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_base_frete_transportadora1]    Script Date: 14/09/2026 12:13:06 ******/
CREATE NONCLUSTERED INDEX [idx_base_frete_transportadora1] ON [dbo].[tb_fin_base_frete_transportadora]
(
	[bft_cd_transportadora] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_tb_fin_pagamento_motorista_IdTransportadora_IdRota_Data]    Script Date: 14/09/2026 12:13:06 ******/
CREATE NONCLUSTERED INDEX [IDX_tb_fin_pagamento_motorista_IdTransportadora_IdRota_Data] ON [dbo].[tb_fin_pagamento_motorista]
(
	[IdTransportadora] ASC,
	[IdRota] ASC,
	[Data] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_tb_fin_prefatura_Rota_Motorista]    Script Date: 14/09/2026 12:13:07 ******/
CREATE NONCLUSTERED INDEX [IDX_tb_fin_prefatura_Rota_Motorista] ON [dbo].[tb_fin_prefatura]
(
	[IdRota] ASC,
	[Motorista] ASC
)
INCLUDE([IdTransportadora]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [IDX_tb_fin_prefatura_Transportadora_Periodo]    Script Date: 14/09/2026 12:13:07 ******/
CREATE NONCLUSTERED INDEX [IDX_tb_fin_prefatura_Transportadora_Periodo] ON [dbo].[tb_fin_prefatura]
(
	[IdTransportadora] ASC,
	[Ano] ASC,
	[Mes] ASC,
	[Quinzena] ASC
)
INCLUDE([IdRota],[Motorista],[Placa],[Total],[VLParada]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_tb_fin_prefatura_idrota]    Script Date: 14/09/2026 12:13:08 ******/
CREATE NONCLUSTERED INDEX [IX_tb_fin_prefatura_idrota] ON [dbo].[tb_fin_prefatura]
(
	[IdRota] ASC
)
INCLUDE([Total]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_tb_fin_prefatura_complementar_rota]    Script Date: 14/09/2026 12:13:08 ******/
CREATE NONCLUSTERED INDEX [IX_tb_fin_prefatura_complementar_rota] ON [dbo].[tb_fin_prefatura_complementar]
(
	[pfc_cd_rota] ASC,
	[pfc_cd_transportadora] ASC,
	[pfc_nu_ano] ASC,
	[pfc_nu_mes] ASC,
	[pfc_nu_quinzena] ASC
)
INCLUDE([pfc_vl_servico]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tb_fin_prefatura_complementar_transp_periodo]    Script Date: 14/09/2026 12:13:08 ******/
CREATE NONCLUSTERED INDEX [IX_tb_fin_prefatura_complementar_transp_periodo] ON [dbo].[tb_fin_prefatura_complementar]
(
	[pfc_cd_transportadora] ASC,
	[pfc_nu_ano] ASC,
	[pfc_nu_mes] ASC,
	[pfc_nu_quinzena] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_IdTransportadora]    Script Date: 14/09/2026 12:13:08 ******/
CREATE NONCLUSTERED INDEX [IDX_IdTransportadora] ON [dbo].[tb_fin_prefatura_descontos]
(
	[IdTransportadora] ASC
)
INCLUDE([Ano],[Mes],[Quinzena],[IdRota]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_Motorista]    Script Date: 14/09/2026 12:13:09 ******/
CREATE NONCLUSTERED INDEX [IDX_Motorista] ON [dbo].[tb_fin_resultado_financeiro]
(
	[Motorista] ASC
)
INCLUDE([DataReferencia],[IdTransportadora],[IdRota]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [IDX_tb_fin_spe_prefatura_Transportadora_Periodo]    Script Date: 14/09/2026 12:13:09 ******/
CREATE NONCLUSTERED INDEX [IDX_tb_fin_spe_prefatura_Transportadora_Periodo] ON [dbo].[tb_fin_spe_prefatura]
(
	[idtransportadora] ASC,
	[ano] ASC,
	[mes] ASC,
	[quinzena] ASC
)
INCLUDE([Rota],[Placa],[FreteCalculado],[ValorFinalReceber]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [idx_tb_fin_spe_prefatura1]    Script Date: 14/09/2026 12:13:10 ******/
CREATE NONCLUSTERED INDEX [idx_tb_fin_spe_prefatura1] ON [dbo].[tb_fin_spe_prefatura]
(
	[idtransportadora] ASC
)
INCLUDE([Rota],[DataPrestacaoServico],[TipoVeiculo]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_FormulariosRespostas_UsuarioCriacao_Cliente_Ativo]    Script Date: 14/09/2026 12:13:10 ******/
CREATE NONCLUSTERED INDEX [IX_FormulariosRespostas_UsuarioCriacao_Cliente_Ativo] ON [dbo].[tb_formularios_respostas]
(
	[frr_cd_usr_criacao] ASC,
	[cli_cd_codigo_cliente] ASC,
	[frr_in_ativo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_grupo_acesso1]    Script Date: 14/09/2026 12:13:10 ******/
CREATE NONCLUSTERED INDEX [idx_grupo_acesso1] ON [dbo].[tb_grupo_acesso]
(
	[gpa_in_ativo] ASC,
	[gpa_cd_cliente] ASC,
	[gpa_in_compartilhado] ASC,
	[gpa_dh_criacao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_GruposAlarmes_Nome_Ordem]    Script Date: 14/09/2026 12:13:10 ******/
CREATE NONCLUSTERED INDEX [IX_GruposAlarmes_Nome_Ordem] ON [dbo].[tb_grupos_alarmes]
(
	[Nome] ASC,
	[Ordem] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_HistoricoAlarmes_IdAlarme_TenantId_Data]    Script Date: 14/09/2026 12:13:10 ******/
CREATE NONCLUSTERED INDEX [IX_HistoricoAlarmes_IdAlarme_TenantId_Data] ON [dbo].[tb_historico_alarmes]
(
	[IdAlarme] ASC,
	[TenantId] ASC,
	[Data] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_HistoricoAlarmes_TenantId]    Script Date: 14/09/2026 12:13:10 ******/
CREATE NONCLUSTERED INDEX [IX_HistoricoAlarmes_TenantId] ON [dbo].[tb_historico_alarmes]
(
	[TenantId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tb_historico_alugueis_Atualizacao]    Script Date: 14/09/2026 12:13:10 ******/
CREATE NONCLUSTERED INDEX [IX_tb_historico_alugueis_Atualizacao] ON [dbo].[tb_historico_alugueis]
(
	[his_dh_atualizacao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tb_historico_alugueis_Criacao]    Script Date: 14/09/2026 12:13:10 ******/
CREATE NONCLUSTERED INDEX [IX_tb_historico_alugueis_Criacao] ON [dbo].[tb_historico_alugueis]
(
	[his_dh_criacao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_tb_historico_alugueis_Placa_CodigoCliente]    Script Date: 14/09/2026 12:13:10 ******/
CREATE NONCLUSTERED INDEX [IX_tb_historico_alugueis_Placa_CodigoCliente] ON [dbo].[tb_historico_alugueis]
(
	[his_ds_placa] ASC,
	[his_cd_cliente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_Municipio_NomeMunicipio_NomeDistrito]    Script Date: 14/09/2026 12:13:10 ******/
CREATE NONCLUSTERED INDEX [IDX_Municipio_NomeMunicipio_NomeDistrito] ON [dbo].[tb_ibge_distritos]
(
	[Municipio] ASC,
	[NomeMunicipio] ASC,
	[NomeDistrito] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_NomeMunicipio_NomeDistrito]    Script Date: 14/09/2026 12:13:10 ******/
CREATE NONCLUSTERED INDEX [IDX_NomeMunicipio_NomeDistrito] ON [dbo].[tb_ibge_distritos]
(
	[NomeMunicipio] ASC,
	[NomeDistrito] ASC
)
INCLUDE([Municipio]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tb_imp_grupo_cliente]    Script Date: 14/09/2026 12:13:10 ******/
CREATE NONCLUSTERED INDEX [IX_tb_imp_grupo_cliente] ON [dbo].[tb_imp_grupo]
(
	[cli_cd_codigo_cliente] ASC,
	[grp_in_ativo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tb_imp_importador_cliente_ativo]    Script Date: 14/09/2026 12:13:10 ******/
CREATE NONCLUSTERED INDEX [IX_tb_imp_importador_cliente_ativo] ON [dbo].[tb_imp_importador]
(
	[cli_cd_codigo_cliente] ASC,
	[imp_in_ativo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tb_imp_importador_grupo]    Script Date: 14/09/2026 12:13:10 ******/
CREATE NONCLUSTERED INDEX [IX_tb_imp_importador_grupo] ON [dbo].[tb_imp_importador]
(
	[grp_cd_grupo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tb_imp_importador_coluna_importador]    Script Date: 14/09/2026 12:13:10 ******/
CREATE NONCLUSTERED INDEX [IX_tb_imp_importador_coluna_importador] ON [dbo].[tb_imp_importador_coluna]
(
	[imp_cd_importador] ASC,
	[imc_nu_ordem] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tb_imp_log_cliente_data]    Script Date: 14/09/2026 12:13:10 ******/
CREATE NONCLUSTERED INDEX [IX_tb_imp_log_cliente_data] ON [dbo].[tb_imp_log]
(
	[cli_cd_codigo_cliente] ASC,
	[ilg_dh_inicio] DESC
)
INCLUDE([imp_cd_importador],[ist_cd_status],[usr_cd_usuario]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tb_imp_log_cliente_importador_data]    Script Date: 14/09/2026 12:13:10 ******/
CREATE NONCLUSTERED INDEX [IX_tb_imp_log_cliente_importador_data] ON [dbo].[tb_imp_log]
(
	[cli_cd_codigo_cliente] ASC,
	[imp_cd_importador] ASC,
	[ilg_dh_inicio] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tb_imp_log_usuario]    Script Date: 14/09/2026 12:13:10 ******/
CREATE NONCLUSTERED INDEX [IX_tb_imp_log_usuario] ON [dbo].[tb_imp_log]
(
	[usr_cd_usuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tb_imp_log_coluna_erro_log]    Script Date: 14/09/2026 12:13:10 ******/
CREATE NONCLUSTERED INDEX [IX_tb_imp_log_coluna_erro_log] ON [dbo].[tb_imp_log_coluna_erro]
(
	[ilg_cd_log] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tb_imp_log_edicao_log]    Script Date: 14/09/2026 12:13:10 ******/
CREATE NONCLUSTERED INDEX [IX_tb_imp_log_edicao_log] ON [dbo].[tb_imp_log_edicao]
(
	[ilg_cd_log] ASC,
	[ied_dh_criacao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tb_imp_log_execucao_script_log]    Script Date: 14/09/2026 12:13:10 ******/
CREATE NONCLUSTERED INDEX [IX_tb_imp_log_execucao_script_log] ON [dbo].[tb_imp_log_execucao_script]
(
	[ilg_cd_log] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_cliente_ativo_excluido_ref]    Script Date: 14/09/2026 12:13:10 ******/
CREATE NONCLUSTERED INDEX [IDX_cliente_ativo_excluido_ref] ON [dbo].[tb_lancamentos_manuais]
(
	[tlm_cd_cliente] ASC,
	[tlm_in_ativo] ASC,
	[tlm_in_excluido] ASC,
	[tlm_dh_referencia] ASC
)
INCLUDE([tlm_cd_rota],[tlm_cd_service_center],[tlm_cd_motorista],[tlm_cd_tipo],[tlm_ds_observacao],[tlm_vl_valor_apoio],[tlm_vl_valor_rota],[tlm_vl_valor_adicional],[tlm_vl_valor_descontos],[tlm_cd_operacao]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_cliente_ativo_excluido_referencia]    Script Date: 14/09/2026 12:13:10 ******/
CREATE NONCLUSTERED INDEX [IDX_cliente_ativo_excluido_referencia] ON [dbo].[tb_lancamentos_manuais]
(
	[tlm_cd_cliente] ASC,
	[tlm_in_ativo] ASC,
	[tlm_in_excluido] ASC,
	[tlm_dh_referencia] ASC
)
INCLUDE([tlm_cd_rota],[tlm_cd_service_center],[tlm_cd_tipo],[tlm_ds_observacao],[tlm_ds_motorista_apoio],[tlm_vl_valor_apoio],[tlm_cd_operacao]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [IDX_lancamentos_data]    Script Date: 14/09/2026 12:13:10 ******/
CREATE NONCLUSTERED INDEX [IDX_lancamentos_data] ON [dbo].[tb_lancamentos_manuais]
(
	[tlm_dh_referencia] ASC
)
INCLUDE([tlm_cd_lancamento_manual],[tlm_cd_rota]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_rota_ativo_excluido_cliente_referencia]    Script Date: 14/09/2026 12:13:10 ******/
CREATE NONCLUSTERED INDEX [IDX_rota_ativo_excluido_cliente_referencia] ON [dbo].[tb_lancamentos_manuais]
(
	[tlm_cd_rota] ASC,
	[tlm_in_ativo] ASC,
	[tlm_in_excluido] ASC,
	[tlm_cd_cliente] ASC,
	[tlm_dh_referencia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_rota_ativo_excluido_operacao_data]    Script Date: 14/09/2026 12:13:10 ******/
CREATE NONCLUSTERED INDEX [IDX_rota_ativo_excluido_operacao_data] ON [dbo].[tb_lancamentos_manuais]
(
	[tlm_cd_rota] ASC,
	[tlm_in_ativo] ASC,
	[tlm_in_excluido] ASC,
	[tlm_cd_operacao] ASC,
	[tlm_dh_referencia] ASC
)
INCLUDE([tlm_cd_service_center],[tlm_cd_motorista],[tlm_cd_tipo],[tlm_ds_observacao],[tlm_cd_cliente],[tlm_ds_motorista_apoio],[tlm_vl_valor_apoio],[tlm_vl_valor_rota],[tlm_vl_valor_adicional],[tlm_vl_valor_descontos]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_tlm_cd_cliente_tlm_in_ativo_tlm_in_excluido_tlm_dh_referencia]    Script Date: 14/09/2026 12:13:10 ******/
CREATE NONCLUSTERED INDEX [IDX_tlm_cd_cliente_tlm_in_ativo_tlm_in_excluido_tlm_dh_referencia] ON [dbo].[tb_lancamentos_manuais]
(
	[tlm_cd_cliente] ASC,
	[tlm_in_ativo] ASC,
	[tlm_in_excluido] ASC,
	[tlm_dh_referencia] ASC
)
INCLUDE([tlm_cd_rota],[tlm_cd_service_center],[tlm_cd_motorista],[tlm_cd_tipo],[tlm_ds_observacao],[tlm_ds_motorista_apoio],[tlm_vl_valor_apoio],[tlm_vl_valor_rota],[tlm_vl_valor_adicional],[tlm_vl_valor_descontos]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_tlm_cd_rota]    Script Date: 14/09/2026 12:13:11 ******/
CREATE NONCLUSTERED INDEX [idx_tlm_cd_rota] ON [dbo].[tb_lancamentos_manuais]
(
	[tlm_cd_rota] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_tlmcdriscoajudante_tlmcdcliente]    Script Date: 14/09/2026 12:13:11 ******/
CREATE NONCLUSTERED INDEX [idx_tlmcdriscoajudante_tlmcdcliente] ON [dbo].[tb_lancamentos_manuais]
(
	[tlm_cd_risco_ajudante] ASC,
	[tlm_cd_cliente] ASC
)
INCLUDE([tlm_cd_rota]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_lancamento_manual]    Script Date: 14/09/2026 12:13:11 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UQ_lancamento_manual] ON [dbo].[tb_lancamentos_manuais]
(
	[tlm_cd_rota] ASC,
	[tlm_cd_service_center] ASC,
	[tlm_cd_motorista] ASC,
	[tlm_cd_tipo] ASC,
	[tlm_cd_periodo] ASC,
	[tlm_cd_cliente] ASC,
	[tlm_dh_referencia] ASC,
	[tlm_cd_operacao] ASC,
	[tlm_ds_observacao] ASC,
	[tlm_vl_valor_adicional] ASC,
	[tlm_vl_valor_descontos] ASC,
	[tlm_vl_valor_apoio] ASC,
	[tlm_ds_placa] ASC
)
WHERE ([tlm_in_excluido]=(0) AND [tlm_in_ativo]=(1))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [ix_lmi_cliente_dh]    Script Date: 14/09/2026 12:13:11 ******/
CREATE NONCLUSTERED INDEX [ix_lmi_cliente_dh] ON [dbo].[tb_lancamentos_manuais_importacao_log]
(
	[lmi_cd_cliente] ASC,
	[lmi_dh_registro] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_data]    Script Date: 14/09/2026 12:13:11 ******/
CREATE NONCLUSTERED INDEX [idx_data] ON [dbo].[tb_layout_pagto_importacao]
(
	[Data] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_id_rota]    Script Date: 14/09/2026 12:13:11 ******/
CREATE NONCLUSTERED INDEX [idx_id_rota] ON [dbo].[tb_layout_pagto_importacao]
(
	[ID_Rota] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_motorista]    Script Date: 14/09/2026 12:13:11 ******/
CREATE NONCLUSTERED INDEX [idx_motorista] ON [dbo].[tb_layout_pagto_importacao]
(
	[Motorista] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_lista_valor]    Script Date: 14/09/2026 12:13:11 ******/
CREATE NONCLUSTERED INDEX [IDX_lista_valor] ON [dbo].[tb_lista]
(
	[lst_ds_valor] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [ix_log_aprovacao_motorista_cliente]    Script Date: 14/09/2026 12:13:11 ******/
CREATE NONCLUSTERED INDEX [ix_log_aprovacao_motorista_cliente] ON [dbo].[tb_log_aprovacao_motorista]
(
	[lam_cd_cliente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [ix_log_aprovacao_motorista_dh]    Script Date: 14/09/2026 12:13:11 ******/
CREATE NONCLUSTERED INDEX [ix_log_aprovacao_motorista_dh] ON [dbo].[tb_log_aprovacao_motorista]
(
	[lam_dh_aprovacao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ix_log_aprovacao_motorista_nome]    Script Date: 14/09/2026 12:13:11 ******/
CREATE NONCLUSTERED INDEX [ix_log_aprovacao_motorista_nome] ON [dbo].[tb_log_aprovacao_motorista]
(
	[lam_nm_motorista] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [ix_log_aprovacao_motorista_sucesso]    Script Date: 14/09/2026 12:13:11 ******/
CREATE NONCLUSTERED INDEX [ix_log_aprovacao_motorista_sucesso] ON [dbo].[tb_log_aprovacao_motorista]
(
	[lam_in_sucesso] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [ix_log_aprovacao_motorista_usuario]    Script Date: 14/09/2026 12:13:11 ******/
CREATE NONCLUSTERED INDEX [ix_log_aprovacao_motorista_usuario] ON [dbo].[tb_log_aprovacao_motorista]
(
	[lam_cd_usuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tb_log_dash_alarmes_dh_captura]    Script Date: 14/09/2026 12:13:11 ******/
CREATE NONCLUSTERED INDEX [IX_tb_log_dash_alarmes_dh_captura] ON [dbo].[tb_log_dash_alarmes]
(
	[dh_captura] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tb_log_dash_alarmes_falha_cliente_alarme]    Script Date: 14/09/2026 12:13:11 ******/
CREATE NONCLUSTERED INDEX [IX_tb_log_dash_alarmes_falha_cliente_alarme] ON [dbo].[tb_log_dash_alarmes]
(
	[cd_valor] ASC,
	[dh_captura] DESC
)
INCLUDE([id_transportadora],[nm_cliente],[nm_alarme]) 
WHERE ([cd_valor]=(1))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [ix_log_importacao_cliente]    Script Date: 14/09/2026 12:13:11 ******/
CREATE NONCLUSTERED INDEX [ix_log_importacao_cliente] ON [dbo].[tb_log_importacao_lancamentos_manuais]
(
	[lim_cd_cliente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [ix_log_importacao_dh_inicio]    Script Date: 14/09/2026 12:13:11 ******/
CREATE NONCLUSTERED INDEX [ix_log_importacao_dh_inicio] ON [dbo].[tb_log_importacao_lancamentos_manuais]
(
	[lim_dh_inicio_execucao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [ix_log_importacao_lancamento]    Script Date: 14/09/2026 12:13:11 ******/
CREATE NONCLUSTERED INDEX [ix_log_importacao_lancamento] ON [dbo].[tb_log_importacao_lancamentos_manuais]
(
	[lim_cd_lancamento_manual] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ix_log_importacao_status]    Script Date: 14/09/2026 12:13:11 ******/
CREATE NONCLUSTERED INDEX [ix_log_importacao_status] ON [dbo].[tb_log_importacao_lancamentos_manuais]
(
	[lim_ds_status_processamento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [ix_log_importacao_usuario]    Script Date: 14/09/2026 12:13:11 ******/
CREATE NONCLUSTERED INDEX [ix_log_importacao_usuario] ON [dbo].[tb_log_importacao_lancamentos_manuais]
(
	[lim_cd_usuario_execucao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [ix_log_resultado_linha]    Script Date: 14/09/2026 12:13:11 ******/
CREATE NONCLUSTERED INDEX [ix_log_resultado_linha] ON [dbo].[tb_log_importacao_lancamentos_manuais_resultado]
(
	[lir_nu_linha] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [ix_log_resultado_log_importacao]    Script Date: 14/09/2026 12:13:11 ******/
CREATE NONCLUSTERED INDEX [ix_log_resultado_log_importacao] ON [dbo].[tb_log_importacao_lancamentos_manuais_resultado]
(
	[lir_cd_log_importacao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ix_log_resultado_status]    Script Date: 14/09/2026 12:13:11 ******/
CREATE NONCLUSTERED INDEX [ix_log_resultado_status] ON [dbo].[tb_log_importacao_lancamentos_manuais_resultado]
(
	[lir_tp_status] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_act_cd_action_ctr_cd_controller]    Script Date: 14/09/2026 12:13:11 ******/
CREATE NONCLUSTERED INDEX [IDX_act_cd_action_ctr_cd_controller] ON [dbo].[tb_logs_acessos]
(
	[act_cd_action] ASC,
	[ctr_cd_controller] ASC
)
INCLUDE([usr_cd_usuario],[log_dh_acesso]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [idx_logs_acessos_1]    Script Date: 14/09/2026 12:13:12 ******/
CREATE NONCLUSTERED INDEX [idx_logs_acessos_1] ON [dbo].[tb_logs_acessos]
(
	[usr_cd_usuario] ASC
)
INCLUDE([log_dh_acesso],[act_cd_action],[ctr_cd_controller]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [IX_tb_looker_treinamentos_geral_timestamp]    Script Date: 14/09/2026 12:13:12 ******/
CREATE NONCLUSTERED INDEX [IX_tb_looker_treinamentos_geral_timestamp] ON [dbo].[tb_looker_treinamentos_geral]
(
	[timestamp] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UX_tb_looker_treinamentos_geral_bkey]    Script Date: 14/09/2026 12:13:12 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UX_tb_looker_treinamentos_geral_bkey] ON [dbo].[tb_looker_treinamentos_geral]
(
	[CodigoCliente] ASC,
	[DRIVER_ID] ASC,
	[COURSE_NAME] ASC,
	[SVC] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_tb_mdfe_log_Etapa]    Script Date: 14/09/2026 12:13:12 ******/
CREATE NONCLUSTERED INDEX [IX_tb_mdfe_log_Etapa] ON [dbo].[tb_mdfe_log]
(
	[Etapa] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tb_mdfe_log_IdLote_DataCriacao]    Script Date: 14/09/2026 12:13:12 ******/
CREATE NONCLUSTERED INDEX [IX_tb_mdfe_log_IdLote_DataCriacao] ON [dbo].[tb_mdfe_log]
(
	[IdLote] ASC,
	[DataCriacao] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tb_mdfe_log_ItemId]    Script Date: 14/09/2026 12:13:12 ******/
CREATE NONCLUSTERED INDEX [IX_tb_mdfe_log_ItemId] ON [dbo].[tb_mdfe_log]
(
	[ItemId] ASC
)
WHERE ([ItemId] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_tb_mdfe_log_Nivel_DataCriacao]    Script Date: 14/09/2026 12:13:12 ******/
CREATE NONCLUSTERED INDEX [IX_tb_mdfe_log_Nivel_DataCriacao] ON [dbo].[tb_mdfe_log]
(
	[Nivel] ASC,
	[DataCriacao] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tb_mdfe_log_TenantId_IdLote]    Script Date: 14/09/2026 12:13:12 ******/
CREATE NONCLUSTERED INDEX [IX_tb_mdfe_log_TenantId_IdLote] ON [dbo].[tb_mdfe_log]
(
	[TenantId] ASC,
	[IdLote] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_mau_cd_cliente_mau_in_excluido]    Script Date: 14/09/2026 12:13:12 ******/
CREATE NONCLUSTERED INDEX [IDX_mau_cd_cliente_mau_in_excluido] ON [dbo].[tb_ml_aprovacao_usuario]
(
	[mau_cd_cliente] ASC,
	[mau_in_excluido] ASC
)
INCLUDE([mau_ds_tipo_documento],[mau_cd_logistics],[mau_ds_documento],[mau_nm_completo],[mau_in_habilitado],[mau_ds_email],[mau_ds_telefone],[mau_ds_status],[mau_cd_usuario_aprovacao],[mau_ds_site],[mau_dh_aprovacao],[mau_cd_usuario_gerado],[mau_in_ativo],[mau_cd_usuario_criacao],[mau_dh_criacao],[mau_cd_usuario_modificacao],[mau_dh_modificacao],[mau_in_reside_area_risco],[mau_ds_origem],[mau_ds_bases_cadastro]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_uk_aprovacao_usuario]    Script Date: 14/09/2026 12:13:13 ******/
CREATE UNIQUE NONCLUSTERED INDEX [idx_uk_aprovacao_usuario] ON [dbo].[tb_ml_aprovacao_usuario]
(
	[mau_ds_email] ASC,
	[mau_cd_cliente] ASC,
	[mau_cd_logistics] ASC
)
WHERE ([mau_ds_status]<>'Reprovado')
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_tb_ml_aprovacao_usuario]    Script Date: 14/09/2026 12:13:13 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_tb_ml_aprovacao_usuario] ON [dbo].[tb_ml_aprovacao_usuario]
(
	[mau_ds_email] ASC,
	[mau_cd_cliente] ASC
)
WHERE ([mau_ds_status]='em análise')
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_tb_ml_aprovacao_usuario_UNIQUE_EMAIL]    Script Date: 14/09/2026 12:13:13 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_tb_ml_aprovacao_usuario_UNIQUE_EMAIL] ON [dbo].[tb_ml_aprovacao_usuario]
(
	[mau_ds_email] ASC,
	[mau_cd_cliente] ASC
)
WHERE ([mau_ds_status]='em análise')
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_tb_ml_aprovacao_usuario_UNIQUE_NOME]    Script Date: 14/09/2026 12:13:13 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_tb_ml_aprovacao_usuario_UNIQUE_NOME] ON [dbo].[tb_ml_aprovacao_usuario]
(
	[mau_nm_completo] ASC,
	[mau_cd_cliente] ASC,
	[mau_ds_documento] ASC
)
WHERE ([mau_ds_status]='em análise')
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_IdRota]    Script Date: 14/09/2026 12:13:13 ******/
CREATE NONCLUSTERED INDEX [IDX_IdRota] ON [dbo].[tb_ml_bsc_rtt]
(
	[IdRota] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_coleta_maps01]    Script Date: 14/09/2026 12:13:13 ******/
CREATE NONCLUSTERED INDEX [idx_coleta_maps01] ON [dbo].[tb_ml_coleta_maps]
(
	[cmm_nm_origem] ASC,
	[cmm_dh_referencia] ASC
)
INCLUDE([cmm_cd_transportadora],[cmm_cd_rota]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [ixd_ml_coleta_maps_process]    Script Date: 14/09/2026 12:13:13 ******/
CREATE NONCLUSTERED INDEX [ixd_ml_coleta_maps_process] ON [dbo].[tb_ml_coleta_maps]
(
	[cmm_in_processado] ASC
)
INCLUDE([cmm_cd_coleta]) 
WHERE ([cmm_in_processado]=(0))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_tb_ml_coleta_totalizador_01]    Script Date: 14/09/2026 12:13:13 ******/
CREATE NONCLUSTERED INDEX [idx_tb_ml_coleta_totalizador_01] ON [dbo].[tb_ml_coleta_totalizador_old]
(
	[cmt_cd_servicecenter] ASC,
	[cmt_dh_escrita] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_Excluido_usuarioda]    Script Date: 14/09/2026 12:13:13 ******/
CREATE NONCLUSTERED INDEX [IDX_Excluido_usuarioda] ON [dbo].[tb_ml_fm_rotas]
(
	[Excluido] ASC,
	[usuarioda] ASC
)
INCLUDE([IdTransportadora],[NomeMotorista]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [IDX_IdTransportadora_Excluido_DataReferencia]    Script Date: 14/09/2026 12:13:14 ******/
CREATE NONCLUSTERED INDEX [IDX_IdTransportadora_Excluido_DataReferencia] ON [dbo].[tb_ml_fm_rotas]
(
	[IdTransportadora] ASC,
	[Excluido] ASC,
	[DataReferencia] ASC
)
INCLUDE([OrigemSaida]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_tb_ml_fm_rotas_01]    Script Date: 14/09/2026 12:13:14 ******/
CREATE NONCLUSTERED INDEX [idx_tb_ml_fm_rotas_01] ON [dbo].[tb_ml_fm_rotas]
(
	[IdTransportadora] ASC,
	[DataReferencia] ASC,
	[NomeMotorista] ASC
)
INCLUDE([usuarioda]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_b_ml_gps_maps_app_01]    Script Date: 14/09/2026 12:13:14 ******/
CREATE NONCLUSTERED INDEX [idx_b_ml_gps_maps_app_01] ON [dbo].[tb_ml_gps_maps_app]
(
	[DataReferencia] ASC
)
INCLUDE([Rota],[IdTransportadora],[Latitude],[Longitude],[Sequencia]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_gps_01]    Script Date: 14/09/2026 12:13:14 ******/
CREATE NONCLUSTERED INDEX [idx_gps_01] ON [dbo].[tb_ml_gps_maps_app]
(
	[DataReferencia] ASC
)
INCLUDE([Rota],[IdTransportadora]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_ml_gps_maps_app_data]    Script Date: 14/09/2026 12:13:14 ******/
CREATE NONCLUSTERED INDEX [idx_ml_gps_maps_app_data] ON [dbo].[tb_ml_gps_maps_app]
(
	[DataReferencia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [idx_tb_ml_gps_maps_app_02]    Script Date: 14/09/2026 12:13:15 ******/
CREATE NONCLUSTERED INDEX [idx_tb_ml_gps_maps_app_02] ON [dbo].[tb_ml_gps_maps_app]
(
	[Rota] ASC,
	[IdTransportadora] ASC,
	[DataReferencia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_tb_ml_gps_maps_geo_01]    Script Date: 14/09/2026 12:13:15 ******/
CREATE NONCLUSTERED INDEX [idx_tb_ml_gps_maps_geo_01] ON [dbo].[tb_ml_gps_maps_geo]
(
	[DataReferencia] ASC
)
INCLUDE([Rota],[IdTransportadora],[Latitude],[Longitude],[Sequencia]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_tb_ml_gps_maps_geo_03]    Script Date: 14/09/2026 12:13:15 ******/
CREATE NONCLUSTERED INDEX [idx_tb_ml_gps_maps_geo_03] ON [dbo].[tb_ml_gps_maps_geo]
(
	[Rota] ASC,
	[IdTransportadora] ASC,
	[DataReferencia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_IdTransportadora,IdRota,IdPacote]    Script Date: 14/09/2026 12:13:15 ******/
CREATE NONCLUSTERED INDEX [idx_IdTransportadora,IdRota,IdPacote] ON [dbo].[tb_ml_hist_insucesso]
(
	[IdTransportadora] ASC,
	[IdRota] ASC,
	[IdPacote] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [IdTransportadora]    Script Date: 14/09/2026 12:13:15 ******/
CREATE NONCLUSTERED INDEX [IdTransportadora] ON [dbo].[tb_ml_motoristas]
(
	[IdTransportadora] ASC
)
INCLUDE([CPF],[CNPJ],[Nome],[Ativo],[Email],[Telefone],[IdSite],[ajudante]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [idx_IdTransportadora]    Script Date: 14/09/2026 12:13:16 ******/
CREATE NONCLUSTERED INDEX [idx_IdTransportadora] ON [dbo].[tb_ml_motoristas]
(
	[IdTransportadora] ASC
)
INCLUDE([Nome],[Telefone]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_IdTransportadora_Nome]    Script Date: 14/09/2026 12:13:16 ******/
CREATE NONCLUSTERED INDEX [idx_IdTransportadora_Nome] ON [dbo].[tb_ml_motoristas]
(
	[IdTransportadora] ASC,
	[Nome] ASC
)
INCLUDE([Telefone]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [idx_c_tb_ml_pacotes]    Script Date: 14/09/2026 12:13:17 ******/
CREATE NONCLUSTERED INDEX [idx_c_tb_ml_pacotes] ON [dbo].[tb_ml_pacotes]
(
	[DataReferencia] ASC,
	[Excluido] ASC,
	[IdTransportadora] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [IDX_DataReferencia_Includes]    Script Date: 14/09/2026 12:13:18 ******/
CREATE NONCLUSTERED INDEX [IDX_DataReferencia_Includes] ON [dbo].[tb_ml_pacotes]
(
	[DataReferencia] ASC
)
INCLUDE([DataAtualizacao]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_DataReferencia_LatitudeEnderecoParada_LongitudeEnderecoParada_CidadeDistante]    Script Date: 14/09/2026 12:13:18 ******/
CREATE NONCLUSTERED INDEX [IDX_DataReferencia_LatitudeEnderecoParada_LongitudeEnderecoParada_CidadeDistante] ON [dbo].[tb_ml_pacotes]
(
	[DataReferencia] ASC,
	[LatitudeEnderecoParada] ASC,
	[LongitudeEnderecoParada] ASC,
	[CidadeDistante] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_Excluido,CidadeDistante,DataReferencia,Cidade]    Script Date: 14/09/2026 12:13:19 ******/
CREATE NONCLUSTERED INDEX [IDX_Excluido,CidadeDistante,DataReferencia,Cidade] ON [dbo].[tb_ml_pacotes]
(
	[Excluido] ASC,
	[CidadeDistante] ASC,
	[DataReferencia] ASC,
	[Cidade] ASC
)
INCLUDE([IdRota],[IdTransportadora]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_Excluido_Cidade_CidDistante_DtRef]    Script Date: 14/09/2026 12:13:19 ******/
CREATE NONCLUSTERED INDEX [IDX_Excluido_Cidade_CidDistante_DtRef] ON [dbo].[tb_ml_pacotes]
(
	[Excluido] ASC,
	[Cidade] ASC,
	[CidadeDistante] ASC,
	[DataReferencia] ASC
)
INCLUDE([LatitudeEnderecoParada],[LongitudeEnderecoParada]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [IDX_Excluido_DataRef_Mult]    Script Date: 14/09/2026 12:13:20 ******/
CREATE NONCLUSTERED INDEX [IDX_Excluido_DataRef_Mult] ON [dbo].[tb_ml_pacotes]
(
	[Excluido] ASC,
	[DataReferencia] ASC
)
INCLUDE([IdPacote],[IdRota],[IdTransportadora],[DataHoraEntrega],[SubStatus],[StatusEntrega],[TipoEndereco],[IdRotaOrigem],[IdRotaDestino],[QuantidadeReclamacoes],[EnderecoParada]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [IDX_Excluido_DataReferencia]    Script Date: 14/09/2026 12:13:20 ******/
CREATE NONCLUSTERED INDEX [IDX_Excluido_DataReferencia] ON [dbo].[tb_ml_pacotes]
(
	[Excluido] ASC,
	[DataReferencia] ASC
)
INCLUDE([IdRota],[IdTransportadora],[SubStatus],[StatusEntrega],[IdParada]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [IDX_Excluido_DataReferencia_includes]    Script Date: 14/09/2026 12:13:21 ******/
CREATE NONCLUSTERED INDEX [IDX_Excluido_DataReferencia_includes] ON [dbo].[tb_ml_pacotes]
(
	[Excluido] ASC,
	[DataReferencia] ASC
)
INCLUDE([IdRota],[IdTransportadora],[SubStatus],[IdParada],[StatusParada],[QuantidadePontosParada]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [IDX_Excluido_DataReferencia_O]    Script Date: 14/09/2026 12:13:21 ******/
CREATE NONCLUSTERED INDEX [IDX_Excluido_DataReferencia_O] ON [dbo].[tb_ml_pacotes]
(
	[Excluido] ASC,
	[DataReferencia] ASC
)
INCLUDE([IdRota],[IdTransportadora],[DataHoraEntrega],[SubStatus],[StatusEntrega],[QuantidadeReclamacoes],[IdParada],[StatusParada],[DataAtualizacao]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [idx_ml_detalhes_pacotes_repr_insucessos]    Script Date: 14/09/2026 12:13:22 ******/
CREATE NONCLUSTERED INDEX [idx_ml_detalhes_pacotes_repr_insucessos] ON [dbo].[tb_ml_pacotes]
(
	[IdPacote] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [idx_ml_pacotes_1]    Script Date: 14/09/2026 12:13:22 ******/
CREATE NONCLUSTERED INDEX [idx_ml_pacotes_1] ON [dbo].[tb_ml_pacotes]
(
	[Excluido] ASC,
	[DataReferencia] ASC,
	[IdRotaOrigem] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [idx_ml_pacotes_data_atual]    Script Date: 14/09/2026 12:13:23 ******/
CREATE NONCLUSTERED INDEX [idx_ml_pacotes_data_atual] ON [dbo].[tb_ml_pacotes]
(
	[DataReferencia] ASC
)
WHERE ([DataReferencia]='2026-09-14')
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_ml_pacotes_repr_insucessos]    Script Date: 14/09/2026 12:13:23 ******/
CREATE NONCLUSTERED INDEX [idx_ml_pacotes_repr_insucessos] ON [dbo].[tb_ml_pacotes]
(
	[IdTransportadora] ASC,
	[DataReferencia] ASC,
	[IdPacote] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [idx_tb_ml_pacotes_01]    Script Date: 14/09/2026 12:13:23 ******/
CREATE NONCLUSTERED INDEX [idx_tb_ml_pacotes_01] ON [dbo].[tb_ml_pacotes]
(
	[IdRota] ASC,
	[IdTransportadora] ASC,
	[DataReferencia] ASC,
	[Excluido] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_tb_ml_pacotes_02]    Script Date: 14/09/2026 12:13:24 ******/
CREATE NONCLUSTERED INDEX [idx_tb_ml_pacotes_02] ON [dbo].[tb_ml_pacotes]
(
	[IdRota] ASC,
	[IdTransportadora] ASC,
	[StatusEntrega] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_tb_ml_pacotes_AuditoriaRota]    Script Date: 14/09/2026 12:13:24 ******/
CREATE NONCLUSTERED INDEX [IX_tb_ml_pacotes_AuditoriaRota] ON [dbo].[tb_ml_pacotes]
(
	[DataReferencia] ASC,
	[StatusEntrega] ASC,
	[Excluido] ASC
)
INCLUDE([IdRota],[IdPacote],[DataHoraEntrega],[LatitudeEnderecoParada],[LongitudeEnderecoParada],[IdTransportadora]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_c_tb_ml_pacotes]    Script Date: 14/09/2026 12:13:24 ******/
CREATE NONCLUSTERED INDEX [idx_c_tb_ml_pacotes] ON [dbo].[tb_ml_pacotes_historico]
(
	[DataReferencia] ASC,
	[Excluido] ASC,
	[IdTransportadora] ASC
)
INCLUDE([IdRota]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_ml_detalhes_pacotes_repr_insucessos]    Script Date: 14/09/2026 12:13:24 ******/
CREATE NONCLUSTERED INDEX [idx_ml_detalhes_pacotes_repr_insucessos] ON [dbo].[tb_ml_pacotes_historico]
(
	[IdPacote] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [idx_ml_pacotes_1]    Script Date: 14/09/2026 12:13:25 ******/
CREATE NONCLUSTERED INDEX [idx_ml_pacotes_1] ON [dbo].[tb_ml_pacotes_historico]
(
	[Excluido] ASC,
	[DataReferencia] ASC,
	[IdRotaOrigem] ASC
)
INCLUDE([IdRota],[IdTransportadora]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [idx_ml_pacotes_2]    Script Date: 14/09/2026 12:13:25 ******/
CREATE NONCLUSTERED INDEX [idx_ml_pacotes_2] ON [dbo].[tb_ml_pacotes_historico]
(
	[Excluido] ASC,
	[DataReferencia] ASC
)
INCLUDE([IdPacote],[IdRota],[IdTransportadora],[DataHoraEntrega],[StatusEntrega]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [idx_ml_pacotes_3]    Script Date: 14/09/2026 12:13:26 ******/
CREATE NONCLUSTERED INDEX [idx_ml_pacotes_3] ON [dbo].[tb_ml_pacotes_historico]
(
	[Excluido] ASC,
	[DataReferencia] ASC
)
INCLUDE([IdRota],[IdTransportadora],[DataHoraEntrega],[StatusEntrega],[QuantidadeReclamacoes],[IdParada],[DataAtualizacao]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [idx_ml_pacotes_4]    Script Date: 14/09/2026 12:13:26 ******/
CREATE NONCLUSTERED INDEX [idx_ml_pacotes_4] ON [dbo].[tb_ml_pacotes_historico]
(
	[Excluido] ASC,
	[DataReferencia] ASC
)
INCLUDE([IdRota],[IdTransportadora],[IdParada],[QuantidadePontosParada]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [idx_ml_pacotes_data_atual]    Script Date: 14/09/2026 12:13:27 ******/
CREATE NONCLUSTERED INDEX [idx_ml_pacotes_data_atual] ON [dbo].[tb_ml_pacotes_historico]
(
	[DataReferencia] ASC
)
WHERE ([DataReferencia]='2025-03-21')
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_ml_pacotes_repr_insucessos]    Script Date: 14/09/2026 12:13:27 ******/
CREATE NONCLUSTERED INDEX [idx_ml_pacotes_repr_insucessos] ON [dbo].[tb_ml_pacotes_historico]
(
	[IdTransportadora] ASC,
	[DataReferencia] ASC,
	[IdPacote] ASC
)
WHERE ([StatusEntrega]='not_delivered' AND [Excluido]=(0))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [idx_tb_ml_pacotes_01]    Script Date: 14/09/2026 12:13:28 ******/
CREATE NONCLUSTERED INDEX [idx_tb_ml_pacotes_01] ON [dbo].[tb_ml_pacotes_historico]
(
	[IdRota] ASC,
	[IdTransportadora] ASC,
	[DataReferencia] ASC,
	[Excluido] ASC
)
INCLUDE([IdPacote],[DataAtualizacao]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_ml_pacotes_maps_1]    Script Date: 14/09/2026 12:13:28 ******/
CREATE NONCLUSTERED INDEX [idx_ml_pacotes_maps_1] ON [dbo].[tb_ml_pacotes_maps]
(
	[IdTransportadora] ASC,
	[DataReferencia] ASC
)
INCLUDE([Rota],[Latitude],[Longitude],[Sequencia]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [idx_ml_pacotes_maps_2]    Script Date: 14/09/2026 12:13:28 ******/
CREATE NONCLUSTERED INDEX [idx_ml_pacotes_maps_2] ON [dbo].[tb_ml_pacotes_maps]
(
	[IdTransportadora] ASC,
	[DataReferencia] ASC
)
INCLUDE([Rota]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [idx_tb_ml_pacotes_maps_01]    Script Date: 14/09/2026 12:13:29 ******/
CREATE NONCLUSTERED INDEX [idx_tb_ml_pacotes_maps_01] ON [dbo].[tb_ml_pacotes_maps]
(
	[DataReferencia] ASC
)
INCLUDE([Rota],[IdTransportadora],[Latitude],[Longitude],[Sequencia]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_tb_ml_pacotes_maps_02]    Script Date: 14/09/2026 12:13:29 ******/
CREATE NONCLUSTERED INDEX [idx_tb_ml_pacotes_maps_02] ON [dbo].[tb_ml_pacotes_maps]
(
	[Rota] ASC,
	[IdTransportadora] ASC,
	[DataReferencia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_ml_pnr]    Script Date: 14/09/2026 12:13:29 ******/
CREATE NONCLUSTERED INDEX [idx_ml_pnr] ON [dbo].[tb_ml_pnr]
(
	[IdPacote] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [idx_ml_pnr_pacote]    Script Date: 14/09/2026 12:13:29 ******/
CREATE NONCLUSTERED INDEX [idx_ml_pnr_pacote] ON [dbo].[tb_ml_pnr]
(
	[IdPacote] ASC
)
INCLUDE([IdReclamacao],[Status]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [IX_tb_ml_pnr_DataReclamacao]    Script Date: 14/09/2026 12:13:30 ******/
CREATE NONCLUSTERED INDEX [IX_tb_ml_pnr_DataReclamacao] ON [dbo].[tb_ml_pnr]
(
	[DataReclamacao] ASC
)
INCLUDE([IdPacote],[Status],[ServiceCenter]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [IDX_idRota_Include]    Script Date: 14/09/2026 12:13:30 ******/
CREATE NONCLUSTERED INDEX [IDX_idRota_Include] ON [dbo].[tb_ml_processamento_km_rotas]
(
	[idRota] ASC
)
INCLUDE([opcaoKmPreFatura],[idRotaGuid]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [IX_ml_processamento_km_rotas_IdRotaGuid]    Script Date: 14/09/2026 12:13:31 ******/
CREATE NONCLUSTERED INDEX [IX_ml_processamento_km_rotas_IdRotaGuid] ON [dbo].[tb_ml_processamento_km_rotas]
(
	[idRotaGuid] ASC,
	[idRota] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [IX_tb_ml_processamento_km_rotas_IdRota]    Script Date: 14/09/2026 12:13:31 ******/
CREATE NONCLUSTERED INDEX [IX_tb_ml_processamento_km_rotas_IdRota] ON [dbo].[tb_ml_processamento_km_rotas]
(
	[idRota] ASC
)
INCLUDE([pontosAppRotasTotalKm]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_Ambulancia_DataReferencia]    Script Date: 14/09/2026 12:13:31 ******/
CREATE NONCLUSTERED INDEX [idx_Ambulancia_DataReferencia] ON [dbo].[tb_ml_rotas]
(
	[Ambulancia] ASC,
	[DataReferencia] ASC
)
INCLUDE([OrigemSaida],[OrigemSaidaAmbulancia]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_c_tb_ml_rotas]    Script Date: 14/09/2026 12:13:32 ******/
CREATE NONCLUSTERED INDEX [idx_c_tb_ml_rotas] ON [dbo].[tb_ml_rotas]
(
	[DataReferencia] ASC,
	[ServiceCenter] ASC,
	[Excluido] ASC,
	[IdTransportadora] ASC
)
INCLUDE([IdRota]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_CidadeDistante,DataReferencia]    Script Date: 14/09/2026 12:13:32 ******/
CREATE NONCLUSTERED INDEX [IDX_CidadeDistante,DataReferencia] ON [dbo].[tb_ml_rotas]
(
	[CidadeDistante] ASC,
	[DataReferencia] ASC
)
INCLUDE([IdRota],[ServiceCenter],[IdTransportadora]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_DataHoraColeta_StatusRota]    Script Date: 14/09/2026 12:13:32 ******/
CREATE NONCLUSTERED INDEX [idx_DataHoraColeta_StatusRota] ON [dbo].[tb_ml_rotas]
(
	[DataHoraColeta] ASC,
	[StatusRota] ASC
)
INCLUDE([ServiceCenter],[IdTransportadora],[TipoVeiculo]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [IDX_DataReferencia_Excluido_DataInicioRota]    Script Date: 14/09/2026 12:13:33 ******/
CREATE NONCLUSTERED INDEX [IDX_DataReferencia_Excluido_DataInicioRota] ON [dbo].[tb_ml_rotas]
(
	[DataReferencia] ASC,
	[Excluido] ASC,
	[DataInicioRota] ASC
)
INCLUDE([IdRota]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_DataReferencia_include]    Script Date: 14/09/2026 12:13:33 ******/
CREATE NONCLUSTERED INDEX [idx_DataReferencia_include] ON [dbo].[tb_ml_rotas]
(
	[DataReferencia] ASC
)
INCLUDE([IdRota],[IdTransportadora],[TotalPacotes],[PacotesEntregues],[PacotesRecebidos],[QuantidadePontos],[QuantidadeParadas],[DataUltimaAtualizacaoPacote],[DataPrimeiraEntrega],[StatusPrimeiraEntrega],[StatusSegundaEntrega],[QuantidadeReclamacoes],[DataUltimaEntrega],[Ambulancia],[OrigemSaidaAmbulancia]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [IDX_dtreferencia_dthorafim]    Script Date: 14/09/2026 12:13:33 ******/
CREATE NONCLUSTERED INDEX [IDX_dtreferencia_dthorafim] ON [dbo].[tb_ml_rotas]
(
	[DataReferencia] ASC,
	[DataHoraFim] ASC
)
INCLUDE([IdRota],[IdTransportadora]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_Excluido_DataReferencia]    Script Date: 14/09/2026 12:13:33 ******/
CREATE NONCLUSTERED INDEX [IDX_Excluido_DataReferencia] ON [dbo].[tb_ml_rotas]
(
	[Excluido] ASC,
	[DataReferencia] ASC
)
INCLUDE([IdRota],[ServiceCenter],[OrigemSaida],[IdTransportadora],[DataHoraInicio],[TotalPacotes],[NomeMotorista],[TipoVeiculo],[QuantidadeParadas],[DataUltimaEntrega]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [IDX_Excluido_DataReferencia_includes]    Script Date: 14/09/2026 12:13:34 ******/
CREATE NONCLUSTERED INDEX [IDX_Excluido_DataReferencia_includes] ON [dbo].[tb_ml_rotas]
(
	[Excluido] ASC,
	[DataReferencia] ASC
)
INCLUDE([IdRota],[ServiceCenter],[OrigemSaida],[IdTransportadora],[DataHoraInicio],[NomeMotorista],[UsuarioDA]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_excluido_status]    Script Date: 14/09/2026 12:13:34 ******/
CREATE NONCLUSTERED INDEX [IDX_excluido_status] ON [dbo].[tb_ml_rotas]
(
	[Excluido] ASC,
	[StatusRota] ASC
)
INCLUDE([IdRota],[ServiceCenter],[UsuarioDA]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_Excluido_Status_CidadeDistante]    Script Date: 14/09/2026 12:13:35 ******/
CREATE NONCLUSTERED INDEX [IDX_Excluido_Status_CidadeDistante] ON [dbo].[tb_ml_rotas]
(
	[Excluido] ASC,
	[StatusRota] ASC,
	[CidadeDistante] ASC
)
INCLUDE([IdRota],[IdTransportadora]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_excluido_status_mult]    Script Date: 14/09/2026 12:13:36 ******/
CREATE NONCLUSTERED INDEX [IDX_excluido_status_mult] ON [dbo].[tb_ml_rotas]
(
	[Excluido] ASC,
	[StatusRota] ASC
)
INCLUDE([IdRota],[DataReferencia],[ServiceCenter],[OrigemSaida],[TipoRota],[SubStatusRota],[IdTransportadora],[DataHoraInicio],[TotalPacotes],[PacotesEntregues],[PacotesNaoEntregue],[PacotesTransferidos],[TotalSacas],[QuantidadeAmbulancia],[StatusPrazo],[NomeMotorista],[NivelExperienciaMotorista],[NivelMotorista],[PossuiAjudante],[Placa],[KmTotal],[TempoEmRota],[TempoAreaEntrega],[DataUltimaAtualizacaoPacote],[DataPrimeiraEntrega],[DataUltimaEntrega],[KmColetadoApp],[Ambulancia],[QuantidadeReclamacoesAbertas],[QuantidadeReclamacoesFechadas],[IdTrevo],[CidadeDistante],[KmMapaPacote],[KmLogistics]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [idx_IdTransportadora_Excluido_DataReferencia]    Script Date: 14/09/2026 12:13:36 ******/
CREATE NONCLUSTERED INDEX [idx_IdTransportadora_Excluido_DataReferencia] ON [dbo].[tb_ml_rotas]
(
	[IdTransportadora] ASC,
	[Excluido] ASC,
	[DataReferencia] ASC
)
INCLUDE([IdRota],[ServiceCenter],[OrigemSaida],[TipoOrigemSaida],[Tipo],[TipoRota],[StatusRota],[SubStatusRota],[DataHoraInicio],[TotalPacotes],[PacotesEntregues],[PacotesNaoEntregue],[PacotesPendentes],[PacotesEntreguesForaAreaEntrega],[PacotesTransferidos],[TotalSacas],[QuantidadeAmbulancia],[StatusPrazo],[NomeMotorista],[NivelExperienciaMotorista],[IdNivelMotorista],[NivelMotorista],[QuantidadePacotesTransportados],[PercentualEntregasBemSucedidas],[PercentualEntregasSemRelamacaoes],[PossuiAjudante],[TipoVeiculo],[Placa],[PercentualProgresso],[KmTotal],[TempoEmRota],[TempoChegadaAreaEntrega],[TempoAreaEntrega],[TempoInativo],[DataAtualizacao],[QuantidadePontos],[QuantidadeParadas],[DataUltimaAtualizacaoPacote],[DataPrimeiraEntrega],[LinkMapa],[StatusPrimeiraEntrega],[StatusSegundaEntrega],[QuantidadeReclamacoes],[KmColetado],[DataUltimaEntrega],[KmColetadoApp],[LinkMapaApp],[Cidades],[CidadeReferencia],[KmMotorista],[LinkAppInterno],[UsouAPP],[UsuarioDA],[Apuracao],[QuantidadeApontamento],[FaixaPrimeiroUltimoPacote],[QuantidadeReclamacoesAbertas],[QuantidadeReclamacoesFechadas],[IdTrevo],[CidadeDistante],[KmMapaPacote],[LinkPacote]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER INDEX [idx_IdTransportadora_Excluido_DataReferencia] ON [dbo].[tb_ml_rotas] DISABLE
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_ml_rotas]    Script Date: 14/09/2026 12:13:36 ******/
CREATE NONCLUSTERED INDEX [idx_ml_rotas] ON [dbo].[tb_ml_rotas]
(
	[ServiceCenter] ASC,
	[IdTransportadora] ASC,
	[Excluido] ASC,
	[DataReferencia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_ml_rotas_data_atual]    Script Date: 14/09/2026 12:13:36 ******/
CREATE NONCLUSTERED INDEX [idx_ml_rotas_data_atual] ON [dbo].[tb_ml_rotas]
(
	[DataReferencia] ASC
)
WHERE ([DataReferencia]='2026-09-14')
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_ml_rotas_motoristas]    Script Date: 14/09/2026 12:13:36 ******/
CREATE NONCLUSTERED INDEX [idx_ml_rotas_motoristas] ON [dbo].[tb_ml_rotas]
(
	[Excluido] ASC
)
INCLUDE([IdRota],[IdTransportadora],[NomeMotorista]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_ml_rotas_motoristas_1]    Script Date: 14/09/2026 12:13:37 ******/
CREATE NONCLUSTERED INDEX [idx_ml_rotas_motoristas_1] ON [dbo].[tb_ml_rotas]
(
	[IdRota] ASC,
	[IdTransportadora] ASC,
	[NomeMotorista] ASC
)
WHERE ([excluido]=(0))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [idx_ml_rotas2]    Script Date: 14/09/2026 12:13:37 ******/
CREATE NONCLUSTERED INDEX [idx_ml_rotas2] ON [dbo].[tb_ml_rotas]
(
	[IdTransportadora] ASC,
	[Excluido] ASC,
	[DataReferencia] ASC
)
INCLUDE([ServiceCenter],[OrigemSaida]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_rotas_fat]    Script Date: 14/09/2026 12:13:37 ******/
CREATE NONCLUSTERED INDEX [idx_rotas_fat] ON [dbo].[tb_ml_rotas]
(
	[IdTransportadora] ASC,
	[DataReferencia] ASC
)
INCLUDE([IdRota],[ServiceCenter],[NomeMotorista]) 
WHERE ([Excluido]=(0))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [idx_rotas_motorista]    Script Date: 14/09/2026 12:13:38 ******/
CREATE NONCLUSTERED INDEX [idx_rotas_motorista] ON [dbo].[tb_ml_rotas]
(
	[DataReferencia] ASC
)
INCLUDE([IdRota],[IdTransportadora],[NomeMotorista]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_tb_ml_rotas]    Script Date: 14/09/2026 12:13:38 ******/
CREATE NONCLUSTERED INDEX [idx_tb_ml_rotas] ON [dbo].[tb_ml_rotas]
(
	[Excluido] ASC,
	[UsuarioDA] ASC,
	[DataReferencia] ASC,
	[StatusRota] ASC
)
INCLUDE([IdTransportadora],[DriverId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_tb_ml_rotas_01]    Script Date: 14/09/2026 12:13:38 ******/
CREATE NONCLUSTERED INDEX [idx_tb_ml_rotas_01] ON [dbo].[tb_ml_rotas]
(
	[Excluido] ASC,
	[DataReferencia] ASC,
	[IdTransportadora] ASC
)
INCLUDE([IdRota],[ServiceCenter],[OrigemSaida]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_tb_ml_rotas_gps]    Script Date: 14/09/2026 12:13:38 ******/
CREATE NONCLUSTERED INDEX [idx_tb_ml_rotas_gps] ON [dbo].[tb_ml_rotas]
(
	[DataReferencia] ASC
)
INCLUDE([IdRota],[StatusRota],[IdTransportadora],[NomeMotorista]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_Transportadoa_excluido_data_status]    Script Date: 14/09/2026 12:13:38 ******/
CREATE NONCLUSTERED INDEX [IDX_Transportadoa_excluido_data_status] ON [dbo].[tb_ml_rotas]
(
	[IdTransportadora] ASC,
	[Excluido] ASC,
	[DataReferencia] ASC,
	[StatusRota] ASC
)
INCLUDE([IdRota],[ServiceCenter],[OrigemSaida],[TipoRota],[SubStatusRota],[DataHoraInicio],[TotalPacotes],[PacotesEntregues],[PacotesNaoEntregue],[PacotesTransferidos],[TotalSacas],[QuantidadeAmbulancia],[StatusPrazo],[NomeMotorista],[NivelExperienciaMotorista],[NivelMotorista],[PossuiAjudante],[TipoVeiculo],[Placa],[KmTotal],[TempoEmRota],[TempoAreaEntrega],[DataUltimaAtualizacaoPacote],[DataPrimeiraEntrega],[DataUltimaEntrega],[KmColetadoApp],[Ambulancia],[QuantidadeReclamacoesAbertas],[QuantidadeReclamacoesFechadas],[IdTrevo],[CidadeDistante],[KmLogistics],[IdKmProcessado]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [IDX_transportadora_Excluido]    Script Date: 14/09/2026 12:13:39 ******/
CREATE NONCLUSTERED INDEX [IDX_transportadora_Excluido] ON [dbo].[tb_ml_rotas]
(
	[IdTransportadora] ASC,
	[Excluido] ASC
)
INCLUDE([IdRota],[DataReferencia],[ServiceCenter],[OrigemSaida],[TipoOrigemSaida],[TipoRota],[StatusRota],[SubStatusRota],[DataHoraInicio],[TotalPacotes],[PacotesEntregues],[PacotesNaoEntregue],[PacotesPendentes],[PacotesEntreguesForaAreaEntrega],[PacotesTransferidos],[TotalSacas],[QuantidadeAmbulancia],[StatusPrazo],[NomeMotorista],[NivelExperienciaMotorista],[IdNivelMotorista],[NivelMotorista],[QuantidadePacotesTransportados],[PercentualEntregasBemSucedidas],[PercentualEntregasSemRelamacaoes],[PossuiAjudante],[TipoVeiculo],[Placa],[PercentualProgresso],[KmTotal],[TempoEmRota],[TempoChegadaAreaEntrega],[TempoAreaEntrega],[TempoInativo],[DataAtualizacao],[QuantidadePontos],[QuantidadeParadas],[DataUltimaAtualizacaoPacote],[DataPrimeiraEntrega],[LinkMapa],[StatusPrimeiraEntrega],[StatusSegundaEntrega],[QuantidadeReclamacoes],[KmColetado],[DataUltimaEntrega],[KmColetadoApp],[LinkMapaApp],[Cidades],[CidadeReferencia],[KmMotorista],[LinkAppInterno],[UsouAPP],[UsuarioDA],[Apuracao],[QuantidadeApontamento],[FaixaPrimeiroUltimoPacote],[QuantidadeReclamacoesAbertas],[QuantidadeReclamacoesFechadas],[IdTrevo],[CidadeDistante],[KmMapaPacote],[LinkPacote],[EnderecosVisitados],[TeveAcaoGps],[QuantidadePnr]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_transportadora_excluido_data_status]    Script Date: 14/09/2026 12:13:39 ******/
CREATE NONCLUSTERED INDEX [IDX_transportadora_excluido_data_status] ON [dbo].[tb_ml_rotas]
(
	[IdTransportadora] ASC,
	[Excluido] ASC,
	[DataReferencia] ASC,
	[StatusRota] ASC
)
INCLUDE([IdRota],[ServiceCenter],[OrigemSaida],[TipoRota],[SubStatusRota],[DataHoraInicio],[TotalPacotes],[PacotesEntregues],[PacotesNaoEntregue],[PacotesTransferidos],[TotalSacas],[QuantidadeAmbulancia],[StatusPrazo],[NomeMotorista],[NivelExperienciaMotorista],[PossuiAjudante],[TipoVeiculo],[Placa],[TempoEmRota],[TempoAreaEntrega],[DataUltimaAtualizacaoPacote],[DataPrimeiraEntrega],[DataUltimaEntrega],[KmColetadoApp],[QuantidadeReclamacoesAbertas],[QuantidadeReclamacoesFechadas],[IdTrevo],[CidadeDistante],[KmMapaPacote]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_transportadora_excluido_referencia_status]    Script Date: 14/09/2026 12:13:39 ******/
CREATE NONCLUSTERED INDEX [IDX_transportadora_excluido_referencia_status] ON [dbo].[tb_ml_rotas]
(
	[IdTransportadora] ASC,
	[Excluido] ASC,
	[DataReferencia] ASC,
	[StatusRota] ASC
)
INCLUDE([IdRota],[ServiceCenter],[OrigemSaida],[TipoRota],[SubStatusRota],[DataHoraInicio],[TotalPacotes],[PacotesEntregues],[PacotesNaoEntregue],[PacotesTransferidos],[TotalSacas],[QuantidadeAmbulancia],[StatusPrazo],[NomeMotorista],[NivelExperienciaMotorista],[NivelMotorista],[PossuiAjudante],[TipoVeiculo],[Placa],[KmTotal],[TempoEmRota],[TempoAreaEntrega],[DataUltimaAtualizacaoPacote],[DataPrimeiraEntrega],[DataUltimaEntrega],[KmColetadoApp],[Ambulancia],[QuantidadeReclamacoesAbertas],[QuantidadeReclamacoesFechadas],[IdTrevo],[CidadeDistante],[KmMapaPacote],[KmLogistics]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_tb_ml_status_entrega_tenant_json]    Script Date: 14/09/2026 12:13:40 ******/
CREATE NONCLUSTERED INDEX [IX_tb_ml_status_entrega_tenant_json] ON [dbo].[tb_ml_status_entrega]
(
	[TenantID] ASC,
	[se_vl_substatus_json] ASC
)
INCLUDE([se_ds_classificacao],[se_ds_status_traduzido]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UX_tb_ml_status_entrega_traducao]    Script Date: 14/09/2026 12:13:40 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UX_tb_ml_status_entrega_traducao] ON [dbo].[tb_ml_status_entrega_traducao]
(
	[TenantID] ASC,
	[StatusEntrega] ASC,
	[SubStatus] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_mot_cd_cliente_mot_cd_status_mot_ds_status_integracao_transportador]    Script Date: 14/09/2026 12:13:40 ******/
CREATE NONCLUSTERED INDEX [idx_mot_cd_cliente_mot_cd_status_mot_ds_status_integracao_transportador] ON [dbo].[tb_motorista]
(
	[mot_cd_cliente] ASC,
	[mot_cd_status] ASC,
	[mot_ds_status_integracao_transportador] ASC
)
INCLUDE([mot_cd_matricula],[mot_cd_foto],[mot_nm_motorista],[mot_cpf],[mot_dt_nascimento],[mot_ctn_cd_tipo_contrato],[mot_ctn_in_status_contrato],[mot_nm_ajudante],[mot_cd_ajudante],[mot_cpf_ajudante],[mot_contato_ajudante],[mot_end_nm_residencia],[mot_end_vl_cep],[mot_end_ds_rua],[mot_end_vl_numero],[mot_end_ds_complemento],[mot_end_nm_bairro],[mot_end_nm_cidade],[mot_end_nm_estado],[mot_pag_nm_empresa],[mot_pag_nm_banco],[mot_pag_nm_titular],[mot_pag_cpf_titular],[mot_pag_cd_agencia],[mot_pag_cd_conta],[mot_pag_ds_tipo_conta],[mot_cnt_vl_celular],[mot_cnt_vl_telefone],[mot_cnt_vl_celular_2],[mot_cnt_vl_email],[mot_cnt_emg_nm_contato],[mot_cnt_emg_vl_telefone],[mot_cnt_emg_vl_celular],[mot_cnt_emg_vl_celular_2],[mot_cnt_emg_grau_parentesco],[mot_emp_ds_tipo],[mot_emp_in_propria],[mot_gr_nm_mae],[mot_gr_nm_pai],[mot_gr_cd_status],[mot_gr_dt_renovacao],[mot_gr_nm_tipo_motorista],[mot_gr_nm_tipo_nacionalidade],[mot_gr_nm_pais_motorista],[mot_gr_vl_rg_motorista],[mot_gr_nm_estado_rg_motorista],[mot_gr_vl_cnh_prontuario_motorista],[mot_gr_vl_cnh_motorista],[mot_gr_dt_primeira_cnh_motorista],[mot_gr_dt_vencimento_cnh_motorista],[mot_gr_nm_tipo_cnh_motorista],[mot_gr_vl_renach_cnh_motorista],[mot_nm_svc],[mot_percentual_cadastro],[mot_ds_status_cadastro],[mot_cd_usuario],[mot_celular_ajudante],[mot_end_nm_pais],[mot_gr_vl_estado_cnh_motorista],[mot_ds_motivo_inativ],[usr_in_fat_motorista_valor_app],[mot_cd_vehicle_year],[mot_ds_plate],[mot_ds_vehicle_rental_value],[mot_ds_vehicle_type],[mot_dt_vehicle_rental_initial],[mot_dt_vehicle_rental_finished],[mot_ds_vehicle_rntrc],[mot_ds_vehicle_antt],[mot_cd_numero_cartao],[mot_ds_status_integracao_motorista],[mot_ds_estado_civil],[mot_ds_nacionalidade],[mot_end_vl_cd_ibge],[mot_cd_vehicle_codigo_target],[mot_ds_orgao_emissor_rg],[mot_pag_cnpj_titular],[mot_in_empresa_target],[mot_ds_empresa_cnpj],[mot_ds_empresa_razao_social],[mot_ds_empresa_nome_fantasia],[mot_ds_empresa_insc_municipal],[mot_ds_empresa_insc_estadual],[mot_ds_empresa_contato_nome],[mot_ds_empresa_contato_cargo],[mot_ds_empresa_contato_cpf],[mot_ds_empresa_contato_celular],[mot_ds_empresa_contato_telefone],[mot_ds_empresa_contato_email],[mot_ds_empresa_contato_rg],[mot_ds_empresa_contato_emissor_rg],[mot_cd_vehicle_fleet_type],[mot_ds_cobranca_modelo],[mot_vehicle_rented],[mot_ds_pix_key_type],[mot_ds_pix_key],[mot_nm_motorista_original],[mot_cd_banco],[mot_vehicle_owner],[mot_cod_proprietario_veiculo],[mot_fl_status_aluguel],[mot_pag_cd_tipo_pagamento],[mot_pis_pasep],[mot_position],[mot_sector]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [idx_motorista_rota]    Script Date: 14/09/2026 12:13:40 ******/
CREATE NONCLUSTERED INDEX [idx_motorista_rota] ON [dbo].[tb_motorista]
(
	[mot_cd_cliente] ASC,
	[mot_cd_motorista] ASC,
	[mot_cd_usuario] ASC
)
INCLUDE([mot_nm_motorista]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [idx_tb_motorista_cliente]    Script Date: 14/09/2026 12:13:41 ******/
CREATE NONCLUSTERED INDEX [idx_tb_motorista_cliente] ON [dbo].[tb_motorista]
(
	[mot_cd_cliente] ASC
)
INCLUDE([mot_nm_motorista],[mot_cd_usuario]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_dh_criacao_cod_cli_mult]    Script Date: 14/09/2026 12:13:41 ******/
CREATE NONCLUSTERED INDEX [IDX_dh_criacao_cod_cli_mult] ON [dbo].[tb_pag_espelhos]
(
	[mtn_dh_criacao] ASC,
	[mtn_cod_cliente] ASC
)
INCLUDE([mtn_cd_motorista],[mtn_cd_pgto_periodo],[mtn_cd_status],[mtn_vl_nfs]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_mot_per_base_opera_stat]    Script Date: 14/09/2026 12:13:41 ******/
CREATE NONCLUSTERED INDEX [IDX_mot_per_base_opera_stat] ON [dbo].[tb_pag_espelhos]
(
	[mtn_cd_motorista] ASC,
	[mtn_cd_pgto_periodo] ASC,
	[mtn_base_principal] ASC,
	[mtn_cd_operacao] ASC,
	[mtn_cd_status] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [IDX_mtn_cd_operacao_mtn_cd_status]    Script Date: 14/09/2026 12:13:42 ******/
CREATE NONCLUSTERED INDEX [IDX_mtn_cd_operacao_mtn_cd_status] ON [dbo].[tb_pag_espelhos]
(
	[mtn_cd_operacao] ASC,
	[mtn_cd_status] ASC
)
INCLUDE([mtn_cd_motorista],[mtn_cd_pgto_periodo],[mtn_base_principal],[mtn_nome_motorista]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_mtn_cd_pgto_periodo]    Script Date: 14/09/2026 12:13:42 ******/
CREATE NONCLUSTERED INDEX [IDX_mtn_cd_pgto_periodo] ON [dbo].[tb_pag_espelhos]
(
	[mtn_cd_pgto_periodo] ASC
)
INCLUDE([mtn_cd_status]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [IDX_mtn_cd_status]    Script Date: 14/09/2026 12:13:42 ******/
CREATE NONCLUSTERED INDEX [IDX_mtn_cd_status] ON [dbo].[tb_pag_espelhos]
(
	[mtn_cd_status] ASC
)
INCLUDE([mtn_cd_motorista],[mtn_cd_pgto_periodo],[mtn_base_principal],[mtn_nome_motorista]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [IDX_mtn_cd_usr_espelho_pdf]    Script Date: 14/09/2026 12:13:43 ******/
CREATE NONCLUSTERED INDEX [IDX_mtn_cd_usr_espelho_pdf] ON [dbo].[tb_pag_espelhos]
(
	[mtn_cd_usr_espelho_pdf] ASC,
	[mtn_in_processamento_em_massa] ASC
)
WHERE ([mtn_cd_usr_espelho_pdf] IS NOT NULL AND [mtn_in_processamento_em_massa]=(1) AND [mtn_in_excluido]=(0))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_mtn_in_processamento_em_massa]    Script Date: 14/09/2026 12:13:43 ******/
CREATE NONCLUSTERED INDEX [IDX_mtn_in_processamento_em_massa] ON [dbo].[tb_pag_espelhos]
(
	[mtn_in_processamento_em_massa] ASC
)
WHERE ([mtn_in_processamento_em_massa]=(1) AND [mtn_in_excluido]=(0))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_pag_espelhos_link_sec]    Script Date: 14/09/2026 12:13:43 ******/
CREATE NONCLUSTERED INDEX [idx_pag_espelhos_link_sec] ON [dbo].[tb_pag_espelhos]
(
	[mtn_cd_motorista_nfs] ASC
)
INCLUDE([mtn_ds_link_nfs_secundario]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [IDX_Periodo]    Script Date: 14/09/2026 12:13:44 ******/
CREATE NONCLUSTERED INDEX [IDX_Periodo] ON [dbo].[tb_pag_espelhos]
(
	[mtn_cd_pgto_periodo] ASC
)
INCLUDE([mtn_cd_motorista],[mtn_vl_nfs]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [IDX_periodo_operacao_mult]    Script Date: 14/09/2026 12:13:44 ******/
CREATE NONCLUSTERED INDEX [IDX_periodo_operacao_mult] ON [dbo].[tb_pag_espelhos]
(
	[mtn_cd_pgto_periodo] ASC,
	[mtn_cd_operacao] ASC
)
INCLUDE([mtn_cd_motorista],[mtn_cod_cliente],[mtn_nome_motorista]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_tb_pag_espelhos_excluido_status]    Script Date: 14/09/2026 12:13:44 ******/
CREATE NONCLUSTERED INDEX [idx_tb_pag_espelhos_excluido_status] ON [dbo].[tb_pag_espelhos]
(
	[mtn_in_excluido] ASC,
	[mtn_cd_status] ASC
)
INCLUDE([mtn_cd_pgto_periodo],[mtn_cd_cliente_transportadora],[mtn_base_principal],[mtn_cd_operacao]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_tb_pag_espelhos_mtn_cd_pgto_periodo02]    Script Date: 14/09/2026 12:13:44 ******/
CREATE NONCLUSTERED INDEX [idx_tb_pag_espelhos_mtn_cd_pgto_periodo02] ON [dbo].[tb_pag_espelhos]
(
	[mtn_cd_pgto_periodo] ASC
)
INCLUDE([mtn_cod_cliente]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tb_pag_espelhos_cliente_periodo_excluido]    Script Date: 14/09/2026 12:13:44 ******/
CREATE NONCLUSTERED INDEX [IX_tb_pag_espelhos_cliente_periodo_excluido] ON [dbo].[tb_pag_espelhos]
(
	[mtn_cd_cliente_transportadora] ASC,
	[mtn_cd_pgto_periodo] ASC,
	[mtn_in_excluido] ASC
)
INCLUDE([mtn_cd_motorista_nfs]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [mtn_tb_pag_espelhos_excluido]    Script Date: 14/09/2026 12:13:44 ******/
CREATE NONCLUSTERED INDEX [mtn_tb_pag_espelhos_excluido] ON [dbo].[tb_pag_espelhos]
(
	[mtn_in_excluido] ASC
)
INCLUDE([mtn_cd_motorista],[mtn_cd_pgto_periodo],[mtn_cod_cliente],[mtn_cd_cliente_transportadora],[mtn_base_principal],[mtn_nome_motorista],[mtn_cd_operacao],[mtn_driver_id]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_espelhos_com_divisao]    Script Date: 14/09/2026 12:13:44 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UQ_espelhos_com_divisao] ON [dbo].[tb_pag_espelhos]
(
	[mtn_cd_pgto_periodo] ASC,
	[mtn_cd_cliente_transportadora] ASC,
	[mtn_cd_operacao] ASC,
	[mtn_nome_motorista] ASC,
	[mtn_cpf] ASC,
	[mtn_base_principal] ASC
)
WHERE ([mtn_in_divisao]=(1) AND [mtn_in_excluido]=(0) AND ([mtn_cod_cliente] IN ((27), (73), (37), (88), (69), (66), (56), (148), (45))))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_espelhos_sem_divisao]    Script Date: 14/09/2026 12:13:44 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UQ_espelhos_sem_divisao] ON [dbo].[tb_pag_espelhos]
(
	[mtn_cd_pgto_periodo] ASC,
	[mtn_cd_cliente_transportadora] ASC,
	[mtn_cd_operacao] ASC,
	[mtn_nome_motorista] ASC,
	[mtn_cpf] ASC
)
WHERE ([mtn_in_divisao]=(0) AND [mtn_in_excluido]=(0) AND ([mtn_cod_cliente] IN ((27), (73), (37), (88), (69), (66), (56), (148), (45))))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_motorista_periodo_cliente_11]    Script Date: 14/09/2026 12:13:44 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UQ_motorista_periodo_cliente_11] ON [dbo].[tb_pag_espelhos]
(
	[mtn_nome_motorista] ASC,
	[mtn_cd_pgto_periodo] ASC,
	[mtn_cd_motorista] ASC,
	[mtn_base_principal] ASC,
	[mtn_cd_operacao] ASC
)
WHERE (([mtn_cod_cliente] IN ((11), (1))) AND [mtn_in_excluido]=(0))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_motorista_periodo_outros_clientes]    Script Date: 14/09/2026 12:13:44 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UQ_motorista_periodo_outros_clientes] ON [dbo].[tb_pag_espelhos]
(
	[mtn_nome_motorista] ASC,
	[mtn_cd_pgto_periodo] ASC,
	[mtn_cd_motorista] ASC,
	[mtn_cd_operacao] ASC,
	[mtn_in_excluido] ASC,
	[mtn_dh_criacao] ASC
)
WHERE ([mtn_cod_cliente]<>(11) AND [mtn_cod_cliente]<>(1) AND [mtn_cod_cliente]<>(56) AND [mtn_cod_cliente]<>(66) AND [mtn_cod_cliente]<>(27) AND [mtn_cod_cliente]<>(73) AND [mtn_cod_cliente]<>(37) AND [mtn_cod_cliente]<>(88) AND [mtn_cod_cliente]<>(69) AND [mtn_cod_cliente]<>(148) AND [mtn_cod_cliente]<>(45))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_tb_pag_espelhos_cliente_11]    Script Date: 14/09/2026 12:13:44 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UQ_tb_pag_espelhos_cliente_11] ON [dbo].[tb_pag_espelhos]
(
	[mtn_nome_motorista] ASC,
	[mtn_cd_pgto_periodo] ASC,
	[mtn_base_principal] ASC,
	[mtn_cd_operacao] ASC
)
WHERE (([mtn_cod_cliente] IN ((11), (1))) AND [mtn_in_excluido]=(0))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_b_pag_espelhos_erros_periodo]    Script Date: 14/09/2026 12:13:44 ******/
CREATE NONCLUSTERED INDEX [idx_b_pag_espelhos_erros_periodo] ON [dbo].[tb_pag_espelhos_erros]
(
	[pee_cd_periodo] ASC,
	[pee_cd_cliente_transportadora] ASC,
	[pee_cd_operacao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_espelhos_erros_motorista_base]    Script Date: 14/09/2026 12:13:44 ******/
CREATE NONCLUSTERED INDEX [IX_espelhos_erros_motorista_base] ON [dbo].[tb_pag_espelhos_erros]
(
	[pee_cd_motorista] ASC,
	[pee_base] ASC
)
INCLUDE([pee_ds_erro],[pee_dh_criacao]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_espelhos_erros_periodo]    Script Date: 14/09/2026 12:13:44 ******/
CREATE NONCLUSTERED INDEX [IX_espelhos_erros_periodo] ON [dbo].[tb_pag_espelhos_erros]
(
	[pee_cd_periodo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_pag_espelhos_logs_1]    Script Date: 14/09/2026 12:13:44 ******/
CREATE NONCLUSTERED INDEX [idx_pag_espelhos_logs_1] ON [dbo].[tb_pag_espelhos_logs]
(
	[lsm_cd_motorista_nfs] ASC,
	[lsm_cd_log_status] DESC
)
INCLUDE([lsm_cd_status_atual],[lsm_cd_usuario]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [idx_pag_espelhos_logs_2]    Script Date: 14/09/2026 12:13:45 ******/
CREATE NONCLUSTERED INDEX [idx_pag_espelhos_logs_2] ON [dbo].[tb_pag_espelhos_logs]
(
	[lsm_cd_motorista_nfs] ASC,
	[lsm_cd_log_status] DESC
)
INCLUDE([lsm_cd_usuario]) 
WHERE ([lsm_cd_status_atual] IN ((36), (37), (38), (39), (40)))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [IX_logs__motorista__logstatus_desc]    Script Date: 14/09/2026 12:13:45 ******/
CREATE NONCLUSTERED INDEX [IX_logs__motorista__logstatus_desc] ON [dbo].[tb_pag_espelhos_logs]
(
	[lsm_cd_motorista_nfs] ASC,
	[lsm_cd_log_status] DESC
)
INCLUDE([lsm_cd_status_atual],[lsm_cd_usuario]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tb_log_status_motorista_nfs]    Script Date: 14/09/2026 12:13:45 ******/
CREATE NONCLUSTERED INDEX [IX_tb_log_status_motorista_nfs] ON [dbo].[tb_pag_espelhos_logs]
(
	[lsm_cd_motorista_nfs] ASC,
	[lsm_dt_data_log] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tb_pag_espelhos_logs_motorista_data_desc]    Script Date: 14/09/2026 12:13:45 ******/
CREATE NONCLUSTERED INDEX [IX_tb_pag_espelhos_logs_motorista_data_desc] ON [dbo].[tb_pag_espelhos_logs]
(
	[lsm_cd_motorista_nfs] ASC,
	[lsm_dt_data_log] DESC
)
INCLUDE([lsm_ds_mensagem]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_nfse_espelho_proc]    Script Date: 14/09/2026 12:13:45 ******/
CREATE NONCLUSTERED INDEX [IX_nfse_espelho_proc] ON [dbo].[tb_pag_espelhos_nfse]
(
	[enf_cd_espelho] ASC,
	[enf_dh_processamento] ASC,
	[enf_qt_tentativas] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UX_tb_pag_integracao_bancos_cd_espelho]    Script Date: 14/09/2026 12:13:45 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UX_tb_pag_integracao_bancos_cd_espelho] ON [dbo].[tb_pag_integracao_bancos]
(
	[pib_cd_espelho] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_tb_parametros_01]    Script Date: 14/09/2026 12:13:45 ******/
CREATE NONCLUSTERED INDEX [idx_tb_parametros_01] ON [dbo].[tb_parametros]
(
	[prm_ds_parametro] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tb_pbi_mon_alertas_fato_consulta]    Script Date: 14/09/2026 12:13:45 ******/
CREATE NONCLUSTERED INDEX [IX_tb_pbi_mon_alertas_fato_consulta] ON [dbo].[tb_pbi_mon_alertas_fato]
(
	[in_elegivel_monitoramento] ASC
)
INCLUDE([id_transportadora],[processo_id],[cd_status],[nm_transportadora],[processo_codigo],[dh_atualizacao],[dt_referencia]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_pbi_mon_etapas_fluxo_ordem]    Script Date: 14/09/2026 12:13:45 ******/
CREATE NONCLUSTERED INDEX [idx_pbi_mon_etapas_fluxo_ordem] ON [dbo].[tb_pbi_mon_etapas]
(
	[fluxo_id] ASC,
	[etapa_ordem] ASC
)
INCLUDE([etapa_nome],[etapa_query_sql]) 
WHERE ([etapa_ativo]=(1))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_pbi_mon_fluxos_processo_id]    Script Date: 14/09/2026 12:13:45 ******/
CREATE NONCLUSTERED INDEX [idx_pbi_mon_fluxos_processo_id] ON [dbo].[tb_pbi_mon_fluxos]
(
	[processo_id] ASC
)
WHERE ([fluxo_ativo]=(1))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tb_pbi_mon_log_alertas_captura]    Script Date: 14/09/2026 12:13:45 ******/
CREATE NONCLUSTERED INDEX [IX_tb_pbi_mon_log_alertas_captura] ON [dbo].[tb_pbi_mon_log_alertas]
(
	[dh_evento] DESC,
	[processo_id] ASC,
	[id_transportadora] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tb_pbi_mon_log_alertas_ultimo]    Script Date: 14/09/2026 12:13:45 ******/
CREATE NONCLUSTERED INDEX [IX_tb_pbi_mon_log_alertas_ultimo] ON [dbo].[tb_pbi_mon_log_alertas]
(
	[id_transportadora] ASC,
	[processo_id] ASC,
	[log_id] DESC
)
INCLUDE([cd_status],[dh_evento]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tb_pbi_mon_processo_acao_log_processo_data]    Script Date: 14/09/2026 12:13:45 ******/
CREATE NONCLUSTERED INDEX [IX_tb_pbi_mon_processo_acao_log_processo_data] ON [dbo].[tb_pbi_mon_processo_acao_log]
(
	[processo_id] ASC,
	[dh_execucao] DESC
)
INCLUDE([in_sucesso],[ds_usuario],[nr_duracao_ms]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [ix_pgto_espelho_import_cliente]    Script Date: 14/09/2026 12:13:45 ******/
CREATE NONCLUSTERED INDEX [ix_pgto_espelho_import_cliente] ON [dbo].[tb_pgto_espelho_importacoes]
(
	[pei_cd_cliente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [ix_pgto_espelho_import_dt_envio]    Script Date: 14/09/2026 12:13:45 ******/
CREATE NONCLUSTERED INDEX [ix_pgto_espelho_import_dt_envio] ON [dbo].[tb_pgto_espelho_importacoes]
(
	[pei_dt_envio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [ix_pgto_espelho_import_periodo]    Script Date: 14/09/2026 12:13:45 ******/
CREATE NONCLUSTERED INDEX [ix_pgto_espelho_import_periodo] ON [dbo].[tb_pgto_espelho_importacoes]
(
	[pei_cd_periodo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [ix_pgto_espelho_import_det_importacao]    Script Date: 14/09/2026 12:13:45 ******/
CREATE NONCLUSTERED INDEX [ix_pgto_espelho_import_det_importacao] ON [dbo].[tb_pgto_espelho_importacoes_detalhes]
(
	[peid_cd_importacao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ix_pgto_espelho_import_det_status]    Script Date: 14/09/2026 12:13:45 ******/
CREATE NONCLUSTERED INDEX [ix_pgto_espelho_import_det_status] ON [dbo].[tb_pgto_espelho_importacoes_detalhes]
(
	[peid_ds_status] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_tb_pgto_cliente]    Script Date: 14/09/2026 12:13:45 ******/
CREATE NONCLUSTERED INDEX [idx_tb_pgto_cliente] ON [dbo].[tb_pgto_periodo]
(
	[pgp_cd_cliente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_tb_pgto_periodo]    Script Date: 14/09/2026 12:13:45 ******/
CREATE NONCLUSTERED INDEX [idx_tb_pgto_periodo] ON [dbo].[tb_pgto_periodo]
(
	[pgp_cd_periodo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tb_pgto_periodo_dt_inicio]    Script Date: 14/09/2026 12:13:45 ******/
CREATE NONCLUSTERED INDEX [IX_tb_pgto_periodo_dt_inicio] ON [dbo].[tb_pgto_periodo]
(
	[pgp_dt_inicio] ASC
)
INCLUDE([pgp_cd_periodo],[pgp_dt_fim]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [<Name of Missing Index, sysname,>]    Script Date: 14/09/2026 12:13:45 ******/
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>] ON [dbo].[tb_pgto_periodo_rota]
(
	[ppr_cd_periodo] ASC
)
INCLUDE([ppr_vl_base],[ppr_vl_paradas],[ppr_vl_risco],[ppr_vl_ajudante],[ppr_vl_dom_fer],[ppr_vl_lancamentos],[ppr_vl_total],[ppr_vl_bonus],[ppr_vl_pedagio],[ppr_vl_aluguel],[ppr_vl_desconto],[ppr_vl_recarga],[ppr_vl_bonus_ds],[ppr_vl_adicional_km]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [IDX_periodo_desconto_lancamento]    Script Date: 14/09/2026 12:13:46 ******/
CREATE NONCLUSTERED INDEX [IDX_periodo_desconto_lancamento] ON [dbo].[tb_pgto_periodo_rota]
(
	[ppr_cd_periodo] ASC,
	[ppr_fl_desconto] ASC,
	[ppr_lcto_cd_lancamento] ASC
)
INCLUDE([ppr_in_excluido],[ppr_cd_motorista_nfs]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [IDX_ppr_cd_periodo]    Script Date: 14/09/2026 12:13:46 ******/
CREATE NONCLUSTERED INDEX [IDX_ppr_cd_periodo] ON [dbo].[tb_pgto_periodo_rota]
(
	[ppr_cd_periodo] ASC
)
INCLUDE([ppr_vl_base],[ppr_vl_paradas],[ppr_vl_risco],[ppr_vl_ajudante],[ppr_vl_dom_fer],[ppr_vl_lancamentos],[ppr_vl_total],[ppr_vl_bonus],[ppr_vl_pedagio],[ppr_vl_aluguel],[ppr_vl_desconto],[ppr_vl_recarga],[ppr_vl_bonus_ds],[ppr_vl_adicional_km]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_ppr_cd_periodo_ppr_cd_rota_ppr_in_excluido_ppr_fl_desconto]    Script Date: 14/09/2026 12:13:47 ******/
CREATE NONCLUSTERED INDEX [IDX_ppr_cd_periodo_ppr_cd_rota_ppr_in_excluido_ppr_fl_desconto] ON [dbo].[tb_pgto_periodo_rota]
(
	[ppr_cd_periodo] ASC,
	[ppr_cd_rota] ASC,
	[ppr_in_excluido] ASC,
	[ppr_fl_desconto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [IDX_ppr_cd_periodo_ppr_fl_desconto]    Script Date: 14/09/2026 12:13:47 ******/
CREATE NONCLUSTERED INDEX [IDX_ppr_cd_periodo_ppr_fl_desconto] ON [dbo].[tb_pgto_periodo_rota]
(
	[ppr_cd_periodo] ASC,
	[ppr_fl_desconto] ASC
)
INCLUDE([ppr_cd_rota],[ppr_cd_faixa_km],[ppr_ds_placa],[ppr_ds_tipo_veiculo],[ppr_ds_ciclo],[ppr_qt_pacotes],[ppr_qt_pontos],[ppr_qt_paradas],[ppr_in_area_risco],[ppr_in_ajudante],[ppr_in_dom_fer],[ppr_vl_base],[ppr_vl_paradas],[ppr_vl_risco],[ppr_vl_ajudante],[ppr_vl_dom_fer],[ppr_vl_lancamentos],[ppr_vl_total_km_real],[ppr_vl_total_km_minimo],[ppr_vl_total_km_prefatura],[ppr_vl_total],[ppr_dh_criacao],[ppr_cd_usr_criacao],[ppr_dh_modificacao],[ppr_cd_usr_modificacao],[ppr_in_ativo],[ppr_in_excluido],[ppr_cd_motorista],[ppr_vl_insucessos],[ppr_vl_success_delivery],[ppr_qt_pacotes_entregues],[ppr_qt_pacotes_pendentes],[ppr_bfm_vl_FaixaKM],[ppr_bfm_vl_adicional_domingo],[ppr_bfm_vl_adicional_ciclo_pm],[ppr_bfm_vl_paradas0_60],[ppr_bfm_vl_paradas61_75],[ppr_bfm_vl_paradas76_85],[ppr_bfm_vl_paradas86_90],[ppr_bfm_vl_paradas_acima_90],[ppr_bfm_vl_adicional_ajudante],[ppr_bfm_vl_adicional_risco],[ppr_bfm_vl_insucesso],[ppr_lcto_dt_lancamento],[ppr_lcto_ciclo],[ppr_lcto_tipo],[ppr_lcto_vl_risco_ajudante],[ppr_lcto_qt_pacotes],[ppr_lcto_qt_pontos],[ppr_lcto_observacao],[ppr_lcto_usr_criacao],[ppr_lcto_dh_modificacao],[ppr_lcto_usr_modificacao],[ppr_lcto_vl_apoio],[ppr_id_transportadora],[ppr_cd_motorista_nfs],[ppr_usou_app],[ppr_data_referencia],[ppr_base_principal],[ppr_tipo_rota],[ppr_nome_motorista],[ppr_cd_pgto_espelho],[ppr_vl_bonus],[ppr_vl_pm],[ppr_vl_valor_frete],[ppr_total_km],[ppr_nm_cidade],[ppr_vl_pedagio],[ppr_lcto_cd_lancamento],[ppr_vl_aluguel],[ppr_vl_desconto],[ppr_vl_recarga],[ppr_vl_pontos],[ppr_vl_pacotes],[ppr_per_endereco_nao_visitado],[ppr_cd_tipo],[ppr_nm_cluster],[ppr_total_km_meli],[ppr_total_km_rtt],[ppr_vl_desconto_flex_rota],[ppr_vl_desconto_cartao_flex_rota],[ppr_in_zerar_vl]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [IDX_ppr_in_excluido_ppr_cd_pgto_espelho]    Script Date: 14/09/2026 12:13:48 ******/
CREATE NONCLUSTERED INDEX [IDX_ppr_in_excluido_ppr_cd_pgto_espelho] ON [dbo].[tb_pgto_periodo_rota]
(
	[ppr_in_excluido] ASC,
	[ppr_cd_pgto_espelho] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [IDX_ppr_lcto_cd_lancamento]    Script Date: 14/09/2026 12:13:48 ******/
CREATE NONCLUSTERED INDEX [IDX_ppr_lcto_cd_lancamento] ON [dbo].[tb_pgto_periodo_rota]
(
	[ppr_lcto_cd_lancamento] ASC
)
INCLUDE([ppr_cd_periodo],[ppr_cd_rota],[ppr_cd_faixa_km],[ppr_ds_placa],[ppr_ds_tipo_veiculo],[ppr_ds_ciclo],[ppr_qt_pacotes],[ppr_qt_pontos],[ppr_qt_paradas],[ppr_in_area_risco],[ppr_in_ajudante],[ppr_in_dom_fer],[ppr_vl_base],[ppr_vl_paradas],[ppr_vl_risco],[ppr_vl_ajudante],[ppr_vl_dom_fer],[ppr_vl_lancamentos],[ppr_vl_total_km_real],[ppr_vl_total_km_minimo],[ppr_vl_total_km_prefatura],[ppr_vl_total],[ppr_dh_criacao],[ppr_cd_usr_criacao],[ppr_dh_modificacao],[ppr_cd_usr_modificacao],[ppr_in_ativo],[ppr_in_excluido],[ppr_cd_motorista],[ppr_vl_insucessos],[ppr_vl_success_delivery],[ppr_qt_pacotes_entregues],[ppr_qt_pacotes_pendentes],[ppr_bfm_vl_FaixaKM],[ppr_bfm_vl_adicional_domingo],[ppr_bfm_vl_adicional_ciclo_pm],[ppr_bfm_vl_paradas0_60],[ppr_bfm_vl_paradas61_75],[ppr_bfm_vl_paradas76_85],[ppr_bfm_vl_paradas86_90],[ppr_bfm_vl_paradas_acima_90],[ppr_bfm_vl_adicional_ajudante],[ppr_bfm_vl_adicional_risco],[ppr_bfm_vl_insucesso],[ppr_lcto_dt_lancamento],[ppr_lcto_ciclo],[ppr_lcto_tipo],[ppr_lcto_vl_risco_ajudante],[ppr_lcto_qt_pacotes],[ppr_lcto_qt_pontos],[ppr_lcto_observacao],[ppr_lcto_usr_criacao],[ppr_lcto_dh_modificacao],[ppr_lcto_usr_modificacao],[ppr_lcto_vl_apoio],[ppr_id_transportadora],[ppr_cd_motorista_nfs],[ppr_usou_app],[ppr_data_referencia],[ppr_base_principal],[ppr_tipo_rota],[ppr_nome_motorista],[ppr_cd_pgto_espelho],[ppr_vl_bonus],[ppr_vl_pm],[ppr_vl_valor_frete],[ppr_total_km],[ppr_nm_cidade],[ppr_vl_pedagio],[ppr_vl_aluguel],[ppr_vl_desconto],[ppr_vl_recarga],[ppr_vl_pontos],[ppr_vl_pacotes],[ppr_per_endereco_nao_visitado],[ppr_cd_tipo],[ppr_nm_cluster],[ppr_total_km_meli],[ppr_total_km_rtt],[ppr_vl_desconto_flex_rota],[ppr_vl_desconto_cartao_flex_rota],[ppr_in_zerar_vl],[ppr_fl_desconto]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [idx_tb_pgto_periodo_rota_ppr_cd_motorista_nfs]    Script Date: 14/09/2026 12:13:49 ******/
CREATE NONCLUSTERED INDEX [idx_tb_pgto_periodo_rota_ppr_cd_motorista_nfs] ON [dbo].[tb_pgto_periodo_rota]
(
	[ppr_cd_motorista_nfs] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_tb_pgto_periodo_rota_espelho_base]    Script Date: 14/09/2026 12:13:49 ******/
CREATE NONCLUSTERED INDEX [IX_tb_pgto_periodo_rota_espelho_base] ON [dbo].[tb_pgto_periodo_rota]
(
	[ppr_cd_pgto_espelho] ASC,
	[ppr_base_principal] ASC
)
WHERE ([ppr_cd_pgto_espelho] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_tb_pgto_periodo_rota_periodo_rota]    Script Date: 14/09/2026 12:13:49 ******/
CREATE NONCLUSTERED INDEX [IX_tb_pgto_periodo_rota_periodo_rota] ON [dbo].[tb_pgto_periodo_rota]
(
	[ppr_cd_periodo] ASC,
	[ppr_cd_rota] ASC
)
INCLUDE([ppr_vl_base],[ppr_vl_total]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UQ_tb_pgto_periodo_rota_lancamento_manual]    Script Date: 14/09/2026 12:13:49 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UQ_tb_pgto_periodo_rota_lancamento_manual] ON [dbo].[tb_pgto_periodo_rota]
(
	[ppr_cd_periodo] ASC,
	[ppr_cd_motorista_nfs] ASC,
	[ppr_lcto_cd_lancamento] ASC
)
WHERE ([ppr_lcto_cd_lancamento] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_edit_cd_espelho]    Script Date: 14/09/2026 12:13:49 ******/
CREATE NONCLUSTERED INDEX [IDX_edit_cd_espelho] ON [dbo].[tb_pgto_periodo_rota_edit]
(
	[edit_cd_espelho] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_edit_cd_periodo]    Script Date: 14/09/2026 12:13:49 ******/
CREATE NONCLUSTERED INDEX [IDX_edit_cd_periodo] ON [dbo].[tb_pgto_periodo_rota_edit]
(
	[edit_cd_periodo] ASC
)
INCLUDE([edit_cd_edit],[edit_rota],[edit_cd_espelho],[edit_Service_Center],[edit_Tipo_Veiculo],[edit_Faixa_KM],[edit_Ciclo_PM],[edit_Placa],[edit_Quantidade_Pontos],[edit_Quantidade_Paradas],[edit_cd_usr_criacao],[edit_dh_criacao],[edit_Quantidade_Pacotes],[edit_usou_app],[edit_Observacao],[edit_Regiao],[edit_RiscoV2],[edit_Ajudante],[edit_AreaRisco],[edit_cidade]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [IDX_edit_cd_periodo_1]    Script Date: 14/09/2026 12:13:49 ******/
CREATE NONCLUSTERED INDEX [IDX_edit_cd_periodo_1] ON [dbo].[tb_pgto_periodo_rota_edit]
(
	[edit_cd_periodo] ASC
)
INCLUDE([edit_cd_edit],[edit_rota],[edit_cd_espelho],[edit_Service_Center],[edit_Tipo_Veiculo],[edit_Faixa_KM],[edit_Ciclo_PM],[edit_Placa],[edit_Quantidade_Pontos],[edit_Quantidade_Paradas],[edit_cd_usr_criacao],[edit_dh_criacao],[edit_Quantidade_Pacotes],[edit_usou_app],[edit_Observacao],[edit_Regiao],[edit_RiscoV2],[edit_Ajudante],[edit_AreaRisco],[edit_cidade],[edit_Total_KM]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_edit_cd_periodo_mult]    Script Date: 14/09/2026 12:13:49 ******/
CREATE NONCLUSTERED INDEX [IDX_edit_cd_periodo_mult] ON [dbo].[tb_pgto_periodo_rota_edit]
(
	[edit_cd_periodo] ASC
)
INCLUDE([edit_rota],[edit_cd_espelho],[edit_Service_Center],[edit_Tipo_Veiculo],[edit_Faixa_KM],[edit_Ciclo_PM],[edit_Placa],[edit_Quantidade_Pontos],[edit_Quantidade_Paradas],[edit_cd_usr_criacao],[edit_dh_criacao],[edit_Quantidade_Pacotes],[edit_usou_app],[edit_Observacao],[edit_Regiao],[edit_RiscoV2],[edit_Ajudante],[edit_AreaRisco],[edit_cidade],[edit_Total_KM],[edit_ambulancia]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [IDX_edit_cd_usr_criacao]    Script Date: 14/09/2026 12:13:50 ******/
CREATE NONCLUSTERED INDEX [IDX_edit_cd_usr_criacao] ON [dbo].[tb_pgto_periodo_rota_edit]
(
	[edit_cd_usr_criacao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_tb_pgto_periodo_rota_erro_periodo]    Script Date: 14/09/2026 12:13:50 ******/
CREATE NONCLUSTERED INDEX [idx_tb_pgto_periodo_rota_erro_periodo] ON [dbo].[tb_pgto_periodo_rota_erro]
(
	[pre_cd_periodo] ASC,
	[pre_cd_cliente_transportadora] ASC,
	[pre_cd_operacao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_rotas_erros_periodo]    Script Date: 14/09/2026 12:13:50 ******/
CREATE NONCLUSTERED INDEX [IX_rotas_erros_periodo] ON [dbo].[tb_pgto_periodo_rota_erro]
(
	[pre_cd_periodo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_rotas_erros_rota]    Script Date: 14/09/2026 12:13:50 ******/
CREATE NONCLUSTERED INDEX [IX_rotas_erros_rota] ON [dbo].[tb_pgto_periodo_rota_erro]
(
	[pre_cd_rota] ASC
)
INCLUDE([pre_base],[pre_ds_erro],[pre_dh_criacao]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_pgto_rotas_espelho]    Script Date: 14/09/2026 12:13:50 ******/
CREATE NONCLUSTERED INDEX [IDX_pgto_rotas_espelho] ON [dbo].[tb_pgto_rotas_lanc_manuais]
(
	[plm_cd_espelhos] ASC,
	[plm_cd_lancamentos] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_processamento_km_rotas_IdRotaGuid]    Script Date: 14/09/2026 12:13:50 ******/
CREATE NONCLUSTERED INDEX [IX_processamento_km_rotas_IdRotaGuid] ON [dbo].[tb_processamento_km_rotas]
(
	[idRota] ASC,
	[idRotaGuid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [idx_registro_gps]    Script Date: 14/09/2026 12:13:50 ******/
CREATE NONCLUSTERED INDEX [idx_registro_gps] ON [dbo].[tb_registro_gps]
(
	[rgp_dh_data_hora] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [idx_registro_gps_1]    Script Date: 14/09/2026 12:13:51 ******/
CREATE NONCLUSTERED INDEX [idx_registro_gps_1] ON [dbo].[tb_registro_gps]
(
	[rgp_cd_usuario] ASC
)
INCLUDE([rgp_dh_data_hora],[rgp_dc_latitude],[rgp_dc_longitude]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [idx_registro_gps_2]    Script Date: 14/09/2026 12:13:51 ******/
CREATE NONCLUSTERED INDEX [idx_registro_gps_2] ON [dbo].[tb_registro_gps]
(
	[rgp_dh_data_hora] ASC,
	[rgp_cd_usuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [idx_registro_gps01]    Script Date: 14/09/2026 12:13:52 ******/
CREATE NONCLUSTERED INDEX [idx_registro_gps01] ON [dbo].[tb_registro_gps]
(
	[rgp_cd_usuario] ASC
)
INCLUDE([rgp_dh_data_hora]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tb_registro_gps_DataUsuario]    Script Date: 14/09/2026 12:13:52 ******/
CREATE NONCLUSTERED INDEX [IX_tb_registro_gps_DataUsuario] ON [dbo].[tb_registro_gps]
(
	[rgp_dh_data_hora] ASC,
	[rgp_cd_usuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_entregas_dataref]    Script Date: 14/09/2026 12:13:52 ******/
CREATE NONCLUSTERED INDEX [IX_entregas_dataref] ON [dbo].[tb_saas_pacotes]
(
	[DataReferencia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_entregas_IdEntrega]    Script Date: 14/09/2026 12:13:52 ******/
CREATE NONCLUSTERED INDEX [IX_entregas_IdEntrega] ON [dbo].[tb_saas_pacotes]
(
	[IdEntrega] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_entregas_IdInternoRota]    Script Date: 14/09/2026 12:13:52 ******/
CREATE NONCLUSTERED INDEX [IX_entregas_IdInternoRota] ON [dbo].[tb_saas_pacotes]
(
	[IdInternoRota] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_sessao_usuario_ativa]    Script Date: 14/09/2026 12:13:52 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_sessao_usuario_ativa] ON [dbo].[tb_sessao_usuario]
(
	[usr_cd_usuario] ASC,
	[ssu_tp_login] ASC
)
WHERE ([ssu_dh_revogada] IS NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_sessao_usuario_sessao_id]    Script Date: 14/09/2026 12:13:52 ******/
CREATE NONCLUSTERED INDEX [IX_sessao_usuario_sessao_id] ON [dbo].[tb_sessao_usuario]
(
	[ssu_ds_sessao_id] ASC
)
WHERE ([ssu_dh_revogada] IS NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [ix_tb_setor_cd_cliente]    Script Date: 14/09/2026 12:13:52 ******/
CREATE NONCLUSTERED INDEX [ix_tb_setor_cd_cliente] ON [dbo].[tb_setor]
(
	[set_cd_cliente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [ix_tb_setor_grupo_acesso_cd_cliente]    Script Date: 14/09/2026 12:13:52 ******/
CREATE NONCLUSTERED INDEX [ix_tb_setor_grupo_acesso_cd_cliente] ON [dbo].[tb_setor_grupo_acesso]
(
	[sga_cd_cliente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_spe_export_rotas_monitoramento]    Script Date: 14/09/2026 12:13:52 ******/
CREATE NONCLUSTERED INDEX [idx_spe_export_rotas_monitoramento] ON [dbo].[tb_spe_export_rotas]
(
	[ser_carrier_id] ASC,
	[ser_station_id] ASC,
	[ser_data_exportacao] ASC,
	[ser_delivering_time] ASC,
	[ser_delivered_time] ASC,
	[ser_onhold_time] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [idx_tb_spe_export_rotas_data]    Script Date: 14/09/2026 12:13:53 ******/
CREATE NONCLUSTERED INDEX [idx_tb_spe_export_rotas_data] ON [dbo].[tb_spe_export_rotas]
(
	[ser_dt_referencia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_spe_motoristas_1]    Script Date: 14/09/2026 12:13:53 ******/
CREATE NONCLUSTERED INDEX [idx_spe_motoristas_1] ON [dbo].[tb_spe_motoristas]
(
	[Transportadora] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [IDX_IdTransportadora_DataReferencia_IdMotorista_Includes]    Script Date: 14/09/2026 12:13:54 ******/
CREATE NONCLUSTERED INDEX [IDX_IdTransportadora_DataReferencia_IdMotorista_Includes] ON [dbo].[tb_spe_pacotes]
(
	[IdTransportadora] ASC,
	[DataReferencia] ASC,
	[IdMotorista] ASC
)
INCLUDE([DataHoraEntrega],[StatusEntrega]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF
GO
/****** Object:  Index [IDX_Data_Excluido]    Script Date: 14/09/2026 12:13:54 ******/
CREATE NONCLUSTERED INDEX [IDX_Data_Excluido] ON [dbo].[tb_spe_pacotes_FM]
(
	[DataCriacaoPacote] ASC,
	[Excluido] ASC
)
INCLUDE([IdTransportadora],[CodigoRota],[CodigoPacote],[StatusPacote],[DataHoraEvento],[DataAtualizacao]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_Id_Excluido]    Script Date: 14/09/2026 12:13:54 ******/
CREATE NONCLUSTERED INDEX [IDX_Id_Excluido] ON [dbo].[tb_spe_pacotes_FM]
(
	[IdTransportadora] ASC,
	[Excluido] ASC
)
INCLUDE([CodigoRota],[CodigoPacote],[StatusPacote],[DataHoraEvento],[DataCriacaoPacote],[DataAtualizacao]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_tb_spe_pacotes_FM_excluido]    Script Date: 14/09/2026 12:13:54 ******/
CREATE NONCLUSTERED INDEX [idx_tb_spe_pacotes_FM_excluido] ON [dbo].[tb_spe_pacotes_FM]
(
	[Excluido] ASC
)
INCLUDE([IdTransportadora],[CodigoRota]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_tb_spe_pacotes_FM_Ranking]    Script Date: 14/09/2026 12:13:54 ******/
CREATE NONCLUSTERED INDEX [IX_tb_spe_pacotes_FM_Ranking] ON [dbo].[tb_spe_pacotes_FM]
(
	[CodigoPacote] ASC,
	[CodigoRota] ASC,
	[DataHoraEvento] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_IdTransportadora_CodigoPacote]    Script Date: 14/09/2026 12:13:54 ******/
CREATE NONCLUSTERED INDEX [IDX_IdTransportadora_CodigoPacote] ON [dbo].[tb_spe_pacotes_lh]
(
	[IdTransportadora] ASC,
	[CodigoPacote] ASC
)
INCLUDE([CodigoRota]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_CodigoRota_IdTransportadora_DataReferencia_StatusEntrega_Latitude_Longitude]    Script Date: 14/09/2026 12:13:55 ******/
CREATE NONCLUSTERED INDEX [IDX_CodigoRota_IdTransportadora_DataReferencia_StatusEntrega_Latitude_Longitude] ON [dbo].[tb_spe_pacotes_novo]
(
	[CodigoRota] ASC,
	[IdTransportadora] ASC,
	[DataReferencia] ASC,
	[StatusEntrega] ASC,
	[Latitude] ASC,
	[Longitude] ASC
)
INCLUDE([DataHoraEntrega]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_CodigoRota_IdTransportadora_DataReferencia_Excluido_StatusEntrega_Latitude_Longitude]    Script Date: 14/09/2026 12:13:55 ******/
CREATE NONCLUSTERED INDEX [IDX_CodigoRota_IdTransportadora_DataReferencia_Excluido_StatusEntrega_Latitude_Longitude] ON [dbo].[tb_spe_pacotes_v4]
(
	[CodigoRota] ASC,
	[IdTransportadora] ASC,
	[DataReferencia] ASC,
	[Excluido] ASC,
	[StatusEntrega] ASC,
	[Latitude] ASC,
	[Longitude] ASC
)
INCLUDE([DataHoraEntrega],[SubStatus]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_CodigoPacote_IdTransportadora_Excluido_DataHoraEntrega]    Script Date: 14/09/2026 12:13:56 ******/
CREATE NONCLUSTERED INDEX [IDX_CodigoPacote_IdTransportadora_Excluido_DataHoraEntrega] ON [dbo].[tb_spe_pacotes_v5]
(
	[CodigoPacote] ASC,
	[IdTransportadora] ASC,
	[Excluido] ASC,
	[DataHoraEntrega] ASC
)
INCLUDE([CodigoRota],[DataReferencia]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_CodigoRota_IdTransportadora_DataReferencia_Excluido_Includes]    Script Date: 14/09/2026 12:13:56 ******/
CREATE NONCLUSTERED INDEX [idx_CodigoRota_IdTransportadora_DataReferencia_Excluido_Includes] ON [dbo].[tb_spe_pacotes_v5]
(
	[CodigoRota] ASC,
	[IdTransportadora] ASC,
	[DataReferencia] ASC,
	[Excluido] ASC
)
INCLUDE([DataHoraEntrega],[StatusEntrega],[SubStatus]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [idx_DataReferencia_Excluido_Includes]    Script Date: 14/09/2026 12:13:57 ******/
CREATE NONCLUSTERED INDEX [idx_DataReferencia_Excluido_Includes] ON [dbo].[tb_spe_pacotes_v5]
(
	[DataReferencia] ASC,
	[Excluido] ASC
)
INCLUDE([CodigoRota],[CodigoPacote],[IdTransportadora],[DataHoraEntrega],[StatusEntrega],[SubStatus],[CEP],[Latitude],[Longitude],[URLImagem],[StatusPacote]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_Excluido_Cidade_CidDIstante_Data]    Script Date: 14/09/2026 12:13:57 ******/
CREATE NONCLUSTERED INDEX [IDX_Excluido_Cidade_CidDIstante_Data] ON [dbo].[tb_spe_pacotes_v5]
(
	[Excluido] ASC,
	[Cidade] ASC,
	[CidadeDistante] ASC,
	[DataReferencia] ASC
)
INCLUDE([Latitude],[Longitude]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_Excluido_DataHoraEntrega]    Script Date: 14/09/2026 12:13:57 ******/
CREATE NONCLUSTERED INDEX [IDX_Excluido_DataHoraEntrega] ON [dbo].[tb_spe_pacotes_v5]
(
	[Excluido] ASC,
	[DataHoraEntrega] ASC
)
INCLUDE([CodigoPacote],[IdTransportadora]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [IDX_IdTransportadora_Excluido]    Script Date: 14/09/2026 12:13:58 ******/
CREATE NONCLUSTERED INDEX [IDX_IdTransportadora_Excluido] ON [dbo].[tb_spe_pacotes_v5]
(
	[IdTransportadora] ASC,
	[Excluido] ASC
)
INCLUDE([CodigoRota],[CodigoPacote],[DataHoraEntrega],[StatusEntrega],[SubStatus],[Latitude],[Longitude]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_tb_spe_pacotes_v5_procs]    Script Date: 14/09/2026 12:13:58 ******/
CREATE NONCLUSTERED INDEX [IX_tb_spe_pacotes_v5_procs] ON [dbo].[tb_spe_pacotes_v5]
(
	[IdTransportadora] ASC,
	[CodigoRota] ASC,
	[CodigoPacote] ASC,
	[DataReferencia] ASC
)
INCLUDE([Latitude],[Longitude],[StatusEntrega],[SubStatus],[RecebidoPor],[DataHoraEntrega],[Excluido]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_tb_spe_processamento_km_rotas_idrota]    Script Date: 14/09/2026 12:13:58 ******/
CREATE NONCLUSTERED INDEX [idx_tb_spe_processamento_km_rotas_idrota] ON [dbo].[tb_spe_processamento_km_rotas]
(
	[idRota] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UX_tb_spe_return_order_transportadora_pacote]    Script Date: 14/09/2026 12:13:58 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UX_tb_spe_return_order_transportadora_pacote] ON [dbo].[tb_spe_return_order]
(
	[idtransportadora] ASC,
	[codigopacote] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_tb_spe_return_order_import_log_codigopacote]    Script Date: 14/09/2026 12:13:58 ******/
CREATE NONCLUSTERED INDEX [IX_tb_spe_return_order_import_log_codigopacote] ON [dbo].[tb_spe_return_order_import_log]
(
	[codigopacote] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tb_spe_return_order_import_log_ProcessId]    Script Date: 14/09/2026 12:13:58 ******/
CREATE NONCLUSTERED INDEX [IX_tb_spe_return_order_import_log_ProcessId] ON [dbo].[tb_spe_return_order_import_log]
(
	[ProcessId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UX_tb_spe_return_order_upload_idtransportadora_tracking]    Script Date: 14/09/2026 12:13:58 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UX_tb_spe_return_order_upload_idtransportadora_tracking] ON [dbo].[tb_spe_return_order_upload]
(
	[idtransportadora] ASC,
	[SLSTrackingNumber] ASC
)
WHERE ([SLSTrackingNumber] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_tb_spe_rotas_01]    Script Date: 14/09/2026 12:13:58 ******/
CREATE NONCLUSTERED INDEX [idx_tb_spe_rotas_01] ON [dbo].[tb_spe_rotas]
(
	[DataReferencia] ASC
)
INCLUDE([IdTransportadora],[IdMotorista]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_tb_spe_rotas_novo_02]    Script Date: 14/09/2026 12:13:58 ******/
CREATE NONCLUSTERED INDEX [idx_tb_spe_rotas_novo_02] ON [dbo].[tb_spe_rotas_novo]
(
	[DataReferencia] ASC
)
INCLUDE([CodigoRota],[IdTransportadora]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_DataReferencia_Excluido]    Script Date: 14/09/2026 12:13:58 ******/
CREATE NONCLUSTERED INDEX [idx_DataReferencia_Excluido] ON [dbo].[tb_spe_rotas_v5]
(
	[DataReferencia] ASC,
	[Excluido] ASC
)
INCLUDE([CodigoRota],[IdTransportadora],[IdStation],[TotalPacotes],[NomeHub]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [IDX_Excluido_TotalPacotes]    Script Date: 14/09/2026 12:13:58 ******/
CREATE NONCLUSTERED INDEX [IDX_Excluido_TotalPacotes] ON [dbo].[tb_spe_rotas_v5]
(
	[Excluido] ASC,
	[TotalPacotes] ASC
)
INCLUDE([CodigoRota],[IdTransportadora]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_Excluido_UsuarioIrisys]    Script Date: 14/09/2026 12:13:58 ******/
CREATE NONCLUSTERED INDEX [IDX_Excluido_UsuarioIrisys] ON [dbo].[tb_spe_rotas_v5]
(
	[Excluido] ASC,
	[UsuarioIrisys] ASC
)
INCLUDE([IdTransportadora],[Motorista]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [idx_IdTransportadora_DataReferencia_Excluido]    Script Date: 14/09/2026 12:13:59 ******/
CREATE NONCLUSTERED INDEX [idx_IdTransportadora_DataReferencia_Excluido] ON [dbo].[tb_spe_rotas_v5]
(
	[IdTransportadora] ASC,
	[DataReferencia] ASC,
	[Excluido] ASC
)
INCLUDE([CodigoRota],[DataHoraInicio],[DataHoraFim],[DataHoraColeta],[IdStation],[IdMotorista],[IdStatus],[DataAtualizacao],[TotalPacotes],[PacotesEntregues],[PacotesNaoEntregue],[PacotesPendentes],[DataUltimaEntrega],[KmColetado],[LinkMapa],[TipoVeiculo],[DataHoraCarga],[Paradas],[CidadeReferencia],[DistanciaTotal],[UsuarioIrisys],[KmApp],[LinkMapaApp],[QuantidadeApontamento],[LinkAppInterno],[Apuracao],[UsouAPP],[NomeHub],[Motorista],[CidadeDistante]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_IdTransportadora_Excluido]    Script Date: 14/09/2026 12:13:59 ******/
CREATE NONCLUSTERED INDEX [IDX_IdTransportadora_Excluido] ON [dbo].[tb_spe_rotas_v5]
(
	[IdTransportadora] ASC,
	[Excluido] ASC
)
INCLUDE([CodigoRota],[NomeHub]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_IdTransportadora_Excluido_UsuarioIrisys]    Script Date: 14/09/2026 12:13:59 ******/
CREATE NONCLUSTERED INDEX [IDX_IdTransportadora_Excluido_UsuarioIrisys] ON [dbo].[tb_spe_rotas_v5]
(
	[IdTransportadora] ASC,
	[Excluido] ASC,
	[UsuarioIrisys] ASC
)
INCLUDE([Motorista]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [idx_tb_spe_rotas_v5_01]    Script Date: 14/09/2026 12:13:59 ******/
CREATE NONCLUSTERED INDEX [idx_tb_spe_rotas_v5_01] ON [dbo].[tb_spe_rotas_v5]
(
	[Excluido] ASC,
	[DataReferencia] ASC
)
INCLUDE([CodigoRota],[IdTransportadora],[TotalPacotes],[PacotesEntregues]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_tb_spe_rotas_v5_1]    Script Date: 14/09/2026 12:13:59 ******/
CREATE NONCLUSTERED INDEX [idx_tb_spe_rotas_v5_1] ON [dbo].[tb_spe_rotas_v5]
(
	[CodigoRota] ASC,
	[Excluido] ASC,
	[DataReferencia] ASC
)
INCLUDE([DataHoraInicio],[TotalPacotes],[DataUltimaEntrega],[TipoVeiculo],[Paradas],[NomeHub],[Motorista]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [IX_tb_spe_rotas_v5_PeriodoMotorista]    Script Date: 14/09/2026 12:14:00 ******/
CREATE NONCLUSTERED INDEX [IX_tb_spe_rotas_v5_PeriodoMotorista] ON [dbo].[tb_spe_rotas_v5]
(
	[DataReferencia] ASC,
	[Excluido] ASC,
	[IdMotorista] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_DadosRotas_data]    Script Date: 14/09/2026 12:14:00 ******/
CREATE NONCLUSTERED INDEX [IX_DadosRotas_data] ON [dbo].[tb_ssrs_spe_monitoramento]
(
	[DataReferencia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_DadosRotas_IdTransportadora]    Script Date: 14/09/2026 12:14:00 ******/
CREATE NONCLUSTERED INDEX [IX_DadosRotas_IdTransportadora] ON [dbo].[tb_ssrs_spe_monitoramento]
(
	[IdTransportadora] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_tb_ssrs_spe_monitoramento_status_pacote]    Script Date: 14/09/2026 12:14:00 ******/
CREATE NONCLUSTERED INDEX [IX_tb_ssrs_spe_monitoramento_status_pacote] ON [dbo].[tb_ssrs_spe_monitoramento_status_pacote]
(
	[idtransportadora] ASC,
	[servicecenter] ASC
)
INCLUDE([CompradorAusente],[NegocioFechado],[EnderecoRuim],[Compradorrejeitado],[ForaRota],[ProblemasMecanicos],[MotoristaSemTempo],[FalhaAplicativo],[AreaRisco],[ClienteMudou],[Outros],[Perdido]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tb_ssrs_spe_monitoramento_status_pacote_data]    Script Date: 14/09/2026 12:14:00 ******/
CREATE NONCLUSTERED INDEX [IX_tb_ssrs_spe_monitoramento_status_pacote_data] ON [dbo].[tb_ssrs_spe_monitoramento_status_pacote]
(
	[datareferencia] ASC
)
INCLUDE([idtransportadora],[servicecenter],[CompradorAusente],[NegocioFechado],[EnderecoRuim],[Compradorrejeitado],[ForaRota],[ProblemasMecanicos],[MotoristaSemTempo],[FalhaAplicativo],[AreaRisco],[ClienteMudou],[Outros],[Perdido]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_stg_dra_historico_rotas_lh_lote]    Script Date: 14/09/2026 12:14:00 ******/
CREATE NONCLUSTERED INDEX [IX_stg_dra_historico_rotas_lh_lote] ON [dbo].[tb_stg_dra_historico_rotas_lh]
(
	[stg_cd_lote] ASC,
	[stg_cd_cliente] ASC
)
INCLUDE([dhl_nr_route_id],[dhl_dh_ultima_atualizacao],[dhl_nr_trecho]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_tb_stg_looker_rtt_DataExtracao]    Script Date: 14/09/2026 12:14:00 ******/
CREATE NONCLUSTERED INDEX [idx_tb_stg_looker_rtt_DataExtracao] ON [dbo].[tb_stg_looker_rtt]
(
	[DataExtracao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_TermosAceitesConfirmados_Usuario_Cliente_Ativo_Excluido]    Script Date: 14/09/2026 12:14:00 ******/
CREATE NONCLUSTERED INDEX [IX_TermosAceitesConfirmados_Usuario_Cliente_Ativo_Excluido] ON [dbo].[tb_termos_aceites_confirmados]
(
	[tac_cd_usuario] ASC,
	[tac_cd_cliente] ASC,
	[tac_in_ativo] ASC,
	[tac_in_excluido] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_usuario_dh_criacao]    Script Date: 14/09/2026 12:14:00 ******/
CREATE NONCLUSTERED INDEX [idx_usuario_dh_criacao] ON [dbo].[tb_usuario]
(
	[usr_dh_criacao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_usuario_motorista]    Script Date: 14/09/2026 12:14:00 ******/
CREATE NONCLUSTERED INDEX [idx_usuario_motorista] ON [dbo].[tb_usuario]
(
	[cli_cd_codigo_cliente] ASC,
	[usr_in_ativo] ASC,
	[usr_in_motorista] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_usuario_reset_token]    Script Date: 14/09/2026 12:14:00 ******/
CREATE NONCLUSTERED INDEX [idx_usuario_reset_token] ON [dbo].[tb_usuario]
(
	[usr_cd_usuario] ASC
)
WHERE ([usr_reset_token]=(1))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_usuario1]    Script Date: 14/09/2026 12:14:01 ******/
CREATE NONCLUSTERED INDEX [idx_usuario1] ON [dbo].[tb_usuario]
(
	[usr_in_ativo] ASC,
	[cli_cd_codigo_cliente] ASC,
	[usr_nm_usuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_usuario3]    Script Date: 14/09/2026 12:14:01 ******/
CREATE NONCLUSTERED INDEX [idx_usuario3] ON [dbo].[tb_usuario]
(
	[cli_cd_codigo_cliente] ASC,
	[usr_nm_usuario] ASC
)
INCLUDE([usr_cd_usuario],[usr_ds_email],[usr_dt_nascimento],[usr_dh_criacao]) 
WHERE ([usr_in_ativo]=(1) AND [usr_in_motorista]=(1))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [uk_tb_usuario_driverid]    Script Date: 14/09/2026 12:14:01 ******/
CREATE UNIQUE NONCLUSTERED INDEX [uk_tb_usuario_driverid] ON [dbo].[tb_usuario]
(
	[cli_cd_codigo_cliente] ASC,
	[usr_cd_driverid] ASC
)
WHERE ([usr_in_ativo]=(1) AND [usr_cd_driverid] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [uk_usuario_nome]    Script Date: 14/09/2026 12:14:01 ******/
CREATE UNIQUE NONCLUSTERED INDEX [uk_usuario_nome] ON [dbo].[tb_usuario]
(
	[usr_nm_usuario] ASC,
	[cli_cd_codigo_cliente] ASC
)
WHERE ([usr_in_ativo]=(1) AND [cli_cd_codigo_cliente]<>(37) AND [cli_cd_codigo_cliente]<>(27))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [uk_usuario_nome_driverid]    Script Date: 14/09/2026 12:14:02 ******/
CREATE UNIQUE NONCLUSTERED INDEX [uk_usuario_nome_driverid] ON [dbo].[tb_usuario]
(
	[usr_nm_usuario] ASC,
	[cli_cd_codigo_cliente] ASC,
	[usr_cd_driverid] ASC
)
WHERE ([usr_in_ativo]=(1) AND ([cli_cd_codigo_cliente] IN ((37), (27))))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [idx_usuario_grupo_acesso_1]    Script Date: 14/09/2026 12:14:02 ******/
CREATE NONCLUSTERED INDEX [idx_usuario_grupo_acesso_1] ON [dbo].[tb_usuario_grupo_acesso]
(
	[uga_cd_grupo_acesso] ASC,
	[uga_cd_usuario] ASC
)
WHERE ([uga_in_ativo]=(1))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [idx_usuario_grupo_acesso_access]    Script Date: 14/09/2026 12:14:03 ******/
CREATE NONCLUSTERED INDEX [idx_usuario_grupo_acesso_access] ON [dbo].[tb_usuario_grupo_acesso]
(
	[uga_cd_usuario] ASC,
	[uga_cd_grupo_acesso] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [ix_tb_usuario_setor_cd_cliente]    Script Date: 14/09/2026 12:14:03 ******/
CREATE NONCLUSTERED INDEX [ix_tb_usuario_setor_cd_cliente] ON [dbo].[tb_usuario_setor]
(
	[use_cd_cliente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [ix_tb_usuario_setor_cd_setor]    Script Date: 14/09/2026 12:14:03 ******/
CREATE NONCLUSTERED INDEX [ix_tb_usuario_setor_cd_setor] ON [dbo].[tb_usuario_setor]
(
	[use_cd_setor] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [ix_tb_usuario_setor_cd_usuario]    Script Date: 14/09/2026 12:14:03 ******/
CREATE NONCLUSTERED INDEX [ix_tb_usuario_setor_cd_usuario] ON [dbo].[tb_usuario_setor]
(
	[use_cd_usuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_rota]    Script Date: 14/09/2026 12:14:03 ******/
CREATE UNIQUE NONCLUSTERED INDEX [idx_rota] ON [dbo].[tb_validacao_mapas]
(
	[vmp_idrota] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_vei_cd_cliente]    Script Date: 14/09/2026 12:14:03 ******/
CREATE NONCLUSTERED INDEX [idx_vei_cd_cliente] ON [dbo].[tb_veiculos]
(
	[vei_cd_cliente] ASC
)
INCLUDE([vei_ds_placa],[vei_in_tipo_frota],[vei_cd_ano]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
/****** Object:  Index [IDX_vei_cd_cliente_composto]    Script Date: 14/09/2026 12:14:04 ******/
CREATE NONCLUSTERED INDEX [IDX_vei_cd_cliente_composto] ON [dbo].[tb_veiculos]
(
	[vei_cd_cliente] ASC
)
INCLUDE([vei_ds_placa],[vei_dh_criacao],[vei_in_tipo_frota],[vei_cd_ano]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_tb_veiculos]    Script Date: 14/09/2026 12:14:04 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UQ_tb_veiculos] ON [dbo].[tb_veiculos]
(
	[vei_ds_placa] ASC,
	[vei_cd_cliente] ASC
)
WHERE ([vei_in_excluido]=(0))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tb_veiculos_proprietarios_motorista]    Script Date: 14/09/2026 12:14:04 ******/
CREATE NONCLUSTERED INDEX [IX_tb_veiculos_proprietarios_motorista] ON [dbo].[tb_veiculos_proprietarios]
(
	[vep_cd_motorista] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tb_veiculos_proprietarios_veiculo]    Script Date: 14/09/2026 12:14:04 ******/
CREATE NONCLUSTERED INDEX [IX_tb_veiculos_proprietarios_veiculo] ON [dbo].[tb_veiculos_proprietarios]
(
	[vep_cd_veiculo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AuditoriaDDL] ADD  DEFAULT (getdate()) FOR [DataEvento]
GO
ALTER TABLE [dbo].[DDL_Backup_Objetos] ADD  DEFAULT (sysdatetime()) FOR [BackupAt]
GO
ALTER TABLE [dbo].[LogConsultasLentas] ADD  DEFAULT (getdate()) FOR [DataRegistro]
GO
ALTER TABLE [dbo].[stg_rotas_lh_csv] ADD  CONSTRAINT [DF_stg_rotas_lh_csv_dh_carga]  DEFAULT (sysdatetime()) FOR [dh_carga]
GO
ALTER TABLE [dbo].[tb_alarmes] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [dbo].[tb_alarmes] ADD  DEFAULT (sysutcdatetime()) FOR [ValidFrom]
GO
ALTER TABLE [dbo].[tb_alarmes] ADD  DEFAULT (CONVERT([datetime2](7),'9999-12-31 23:59:59.9999999')) FOR [ValidTo]
GO
ALTER TABLE [dbo].[tb_ama_anexo_motorista] ADD  CONSTRAINT [df_tb_ama_anexo_motorista_nome]  DEFAULT ('') FOR [ama_ds_nome]
GO
ALTER TABLE [dbo].[tb_ama_anexo_motorista] ADD  CONSTRAINT [df_tb_ama_anexo_motorista_data]  DEFAULT (getdate()) FOR [ama_cd_data_anexo]
GO
ALTER TABLE [dbo].[tb_ama_anexo_motorista] ADD  CONSTRAINT [df_tb_ama_anexo_motorista_ativo]  DEFAULT ((1)) FOR [ama_in_ativo]
GO
ALTER TABLE [dbo].[tb_ama_anexo_motorista] ADD  CONSTRAINT [df_tb_ama_anexo_motorista_excluido]  DEFAULT ((0)) FOR [ama_in_excluido]
GO
ALTER TABLE [dbo].[tb_ans_anexo_sinistro] ADD  DEFAULT (getdate()) FOR [ans_cd_data_anexo]
GO
ALTER TABLE [dbo].[tb_ans_anexo_sinistro] ADD  DEFAULT ((1)) FOR [ans_in_ativo]
GO
ALTER TABLE [dbo].[tb_ans_anexo_sinistro] ADD  DEFAULT ((0)) FOR [ans_in_excluido]
GO
ALTER TABLE [dbo].[tb_aprovacao_lancamento_manual] ADD  DEFAULT ('Aguardando Aprovação') FOR [alm_ds_status]
GO
ALTER TABLE [dbo].[tb_aprovacao_lancamento_manual] ADD  DEFAULT ((1)) FOR [alm_in_ativo]
GO
ALTER TABLE [dbo].[tb_aprovacao_lancamento_manual] ADD  DEFAULT ((0)) FOR [alm_in_excluido]
GO
ALTER TABLE [dbo].[tb_aprovacao_lancamento_manual] ADD  DEFAULT (sysutcdatetime()) FOR [ValidFrom]
GO
ALTER TABLE [dbo].[tb_aprovacao_lancamento_manual] ADD  DEFAULT (CONVERT([datetime2](7),'9999-12-31 23:59:59.9999999')) FOR [ValidTo]
GO
ALTER TABLE [dbo].[tb_arquivos_blob] ADD  DEFAULT (getdate()) FOR [datahora]
GO
ALTER TABLE [dbo].[tb_azure_DadosAparelhos] ADD  DEFAULT ('') FOR [versionApp]
GO
ALTER TABLE [dbo].[tb_bases] ADD  CONSTRAINT [DF__tb_bases__bss_dc__6D031153]  DEFAULT ((0)) FOR [bss_dc_latitude]
GO
ALTER TABLE [dbo].[tb_bases] ADD  CONSTRAINT [DF__tb_bases__bss_dc__6DF7358C]  DEFAULT ((0)) FOR [bss_dc_longitude]
GO
ALTER TABLE [dbo].[tb_bases] ADD  CONSTRAINT [DF__tb_bases__bss_in__5066D2A5]  DEFAULT ((0)) FOR [bss_in_xpt]
GO
ALTER TABLE [dbo].[tb_bases] ADD  CONSTRAINT [DF__tb_bases__bss_in__515AF6DE]  DEFAULT ((1)) FOR [bss_in_status]
GO
ALTER TABLE [dbo].[tb_bases] ADD  CONSTRAINT [DF__tb_bases__bss_in__524F1B17]  DEFAULT ((0)) FOR [bss_in_excluido]
GO
ALTER TABLE [dbo].[tb_bases] ADD  DEFAULT (getdate()) FOR [ValidFrom]
GO
ALTER TABLE [dbo].[tb_bases] ADD  DEFAULT (CONVERT([datetime2](7),'9999-12-31 23:59:59.9999999')) FOR [ValidTo]
GO
ALTER TABLE [dbo].[tb_bases_profissionais] ADD  DEFAULT (newid()) FOR [tbp_cd_base_profissional]
GO
ALTER TABLE [dbo].[tb_cidades_regiao_nao_identificadas_api] ADD  DEFAULT ((1)) FOR [Ativo]
GO
ALTER TABLE [dbo].[tb_cidades_regiao_nao_identificadas_api] ADD  DEFAULT (getdate()) FOR [DataCriacao]
GO
ALTER TABLE [dbo].[tb_classificacao_tributaria_ibscbs] ADD  DEFAULT (newsequentialid()) FOR [Id]
GO
ALTER TABLE [dbo].[tb_classificacao_tributaria_ibscbs] ADD  CONSTRAINT [DF_tb_classificacao_tributaria_ibscbs_AplicavelCte]  DEFAULT ((0)) FOR [AplicavelCte]
GO
ALTER TABLE [dbo].[tb_classificacao_tributaria_ibscbs] ADD  CONSTRAINT [DF_tb_classificacao_tributaria_ibscbs_AplicavelNfe]  DEFAULT ((0)) FOR [AplicavelNfe]
GO
ALTER TABLE [dbo].[tb_classificacao_tributaria_ibscbs] ADD  CONSTRAINT [DF_tb_classificacao_tributaria_ibscbs_Excluido]  DEFAULT ((0)) FOR [Excluido]
GO
ALTER TABLE [dbo].[tb_clientes] ADD  DEFAULT ((0)) FOR [cli_in_app_documentos]
GO
ALTER TABLE [dbo].[tb_clientes] ADD  DEFAULT (newid()) FOR [TokenAPIMonitor]
GO
ALTER TABLE [dbo].[tb_comprovantes] ADD  DEFAULT ((1)) FOR [cmp_in_ativo]
GO
ALTER TABLE [dbo].[tb_comprovantes] ADD  DEFAULT ((0)) FOR [cmp_in_excluido]
GO
ALTER TABLE [dbo].[tb_comprovantes] ADD  DEFAULT ((0)) FOR [cmp_in_pix_gr]
GO
ALTER TABLE [dbo].[tb_comprovantes_enviados] ADD  DEFAULT ((1)) FOR [cme_in_ativo]
GO
ALTER TABLE [dbo].[tb_comprovantes_enviados] ADD  DEFAULT ((0)) FOR [cme_in_excluido]
GO
ALTER TABLE [dbo].[tb_comprovantes_enviados] ADD  CONSTRAINT [DF_tb_comprovantes_enviados_solicita_envio]  DEFAULT ((0)) FOR [cme_in_solicita_envio_atualizado]
GO
ALTER TABLE [dbo].[tb_comprovantes_pagamento_seguradora] ADD  DEFAULT ((1)) FOR [cps_in_ativo]
GO
ALTER TABLE [dbo].[tb_comprovantes_pagamento_seguradora] ADD  DEFAULT ((0)) FOR [cps_in_excluido]
GO
ALTER TABLE [dbo].[tb_comprovantes_tipo_contrato] ADD  DEFAULT ((1)) FOR [ctc_in_ativo]
GO
ALTER TABLE [dbo].[tb_comprovantes_tipo_contrato] ADD  DEFAULT ((0)) FOR [ctc_in_excluido]
GO
ALTER TABLE [dbo].[tb_conferencia_cargas_pacotes_inconsistente] ADD  DEFAULT (getdate()) FOR [cne_dh_conferencia]
GO
ALTER TABLE [dbo].[tb_contratos] ADD  DEFAULT ((1)) FOR [ctt_in_ativo]
GO
ALTER TABLE [dbo].[tb_contratos] ADD  DEFAULT ((0)) FOR [ctt_in_excluido]
GO
ALTER TABLE [dbo].[tb_contratos_assinados] ADD  CONSTRAINT [df_contratos_assinados_codigo_assinatura]  DEFAULT (newid()) FOR [cta_ds_codigo_assinatura]
GO
ALTER TABLE [dbo].[tb_contratos_assinados_eventos] ADD  CONSTRAINT [df_contratos_eventos_codigo_assinatura]  DEFAULT (newid()) FOR [cte_ds_codigo_assinatura]
GO
ALTER TABLE [dbo].[tb_contratos_assinatura_onboarding] ADD  DEFAULT (getdate()) FOR [cao_dh_criacao]
GO
ALTER TABLE [dbo].[tb_contratos_documentos_enviados] ADD  DEFAULT ((1)) FOR [cde_in_ativo]
GO
ALTER TABLE [dbo].[tb_contratos_documentos_enviados] ADD  DEFAULT ((0)) FOR [cde_in_excluido]
GO
ALTER TABLE [dbo].[tb_contratos_documentos_necessarios] ADD  DEFAULT ((1)) FOR [cdn_in_ativo]
GO
ALTER TABLE [dbo].[tb_contratos_documentos_necessarios] ADD  DEFAULT ((0)) FOR [cdn_in_excluido]
GO
ALTER TABLE [dbo].[tb_contratos_tipo_contrato] ADD  DEFAULT ((1)) FOR [ctn_in_ativo]
GO
ALTER TABLE [dbo].[tb_contratos_tipo_contrato] ADD  DEFAULT ((0)) FOR [ctn_in_excluido]
GO
ALTER TABLE [dbo].[tb_controller] ADD  DEFAULT ('Sistema') FOR [ctr_ds_modulo]
GO
ALTER TABLE [dbo].[tb_controller] ADD  CONSTRAINT [DF_tb_controller_ctrl_ds_funcionalidade_acesso]  DEFAULT ('todos') FOR [ctrl_ds_funcionalidade_acesso]
GO
ALTER TABLE [dbo].[tb_crud_teste] ADD  DEFAULT ((0)) FOR [tst_in_ativo]
GO
ALTER TABLE [dbo].[tb_cte_log] ADD  CONSTRAINT [DF_tb_cte_log_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[tb_cte_log] ADD  CONSTRAINT [DF_tb_cte_log_DataCriacao]  DEFAULT (getdate()) FOR [DataCriacao]
GO
ALTER TABLE [dbo].[tb_cte_log] ADD  CONSTRAINT [DF_tb_cte_log_Nivel]  DEFAULT ('ERROR') FOR [Nivel]
GO
ALTER TABLE [dbo].[tb_cte_lotes] ADD  DEFAULT ((0)) FOR [cte_in_unificar_ctes]
GO
ALTER TABLE [dbo].[tb_cte_regra_ibscbs] ADD  DEFAULT (newsequentialid()) FOR [Id]
GO
ALTER TABLE [dbo].[tb_cte_regra_ibscbs] ADD  CONSTRAINT [DF_tb_cte_regra_ibscbs_Prioridade]  DEFAULT ((0)) FOR [Prioridade]
GO
ALTER TABLE [dbo].[tb_cte_regra_ibscbs] ADD  CONSTRAINT [DF_tb_cte_regra_ibscbs_Excluido]  DEFAULT ((0)) FOR [Excluido]
GO
ALTER TABLE [dbo].[tb_dim_faixa_km] ADD  DEFAULT (getdate()) FOR [dt_criacao]
GO
ALTER TABLE [dbo].[tb_dim_faixa_km] ADD  DEFAULT (getdate()) FOR [dt_atualizacao]
GO
ALTER TABLE [dbo].[tb_dim_faixa_km] ADD  DEFAULT ((1)) FOR [in_ativo]
GO
ALTER TABLE [dbo].[tb_disponibilidade_motorista] ADD  DEFAULT ((0)) FOR [dpm_in_excluido]
GO
ALTER TABLE [dbo].[tb_disponibilidade_motorista] ADD  DEFAULT ((0)) FOR [dpm_in_disponivel]
GO
ALTER TABLE [dbo].[tb_documentos] ADD  DEFAULT ((1)) FOR [dcm_in_ativo]
GO
ALTER TABLE [dbo].[tb_documentos] ADD  DEFAULT ((0)) FOR [dcm_in_excluido]
GO
ALTER TABLE [dbo].[tb_documentos_enviados] ADD  DEFAULT ((1)) FOR [dce_in_ativo]
GO
ALTER TABLE [dbo].[tb_documentos_enviados] ADD  DEFAULT ((0)) FOR [dce_in_excluido]
GO
ALTER TABLE [dbo].[tb_documentos_tipo_contrato] ADD  DEFAULT ((1)) FOR [dtc_in_ativo]
GO
ALTER TABLE [dbo].[tb_documentos_tipo_contrato] ADD  DEFAULT ((0)) FOR [dtc_in_excluido]
GO
ALTER TABLE [dbo].[tb_empresas] ADD  DEFAULT ((0)) FOR [emp_in_emissao_cte]
GO
ALTER TABLE [dbo].[tb_empresas] ADD  DEFAULT ((0)) FOR [emp_in_matriz]
GO
ALTER TABLE [dbo].[tb_envio_boas_vindas_lote] ADD  DEFAULT (getdate()) FOR [evl_dh_criacao]
GO
ALTER TABLE [dbo].[tb_envio_boas_vindas_lote] ADD  DEFAULT ((0)) FOR [evl_qt_total]
GO
ALTER TABLE [dbo].[tb_envio_boas_vindas_lote] ADD  DEFAULT ((0)) FOR [evl_qt_sucesso]
GO
ALTER TABLE [dbo].[tb_envio_boas_vindas_lote] ADD  DEFAULT ((0)) FOR [evl_qt_falha]
GO
ALTER TABLE [dbo].[tb_envio_boas_vindas_lote] ADD  DEFAULT ((0)) FOR [evl_in_excluido]
GO
ALTER TABLE [dbo].[tb_envio_boas_vindas_lote_detalhe] ADD  DEFAULT ('Aguardando') FOR [evld_ds_status]
GO
ALTER TABLE [dbo].[tb_envio_relatios] ADD  DEFAULT ((0)) FOR [er_in_excluido]
GO
ALTER TABLE [dbo].[tb_envio_relatios] ADD  DEFAULT ((0)) FOR [er_in_configuracao_em_grupo]
GO
ALTER TABLE [dbo].[tb_faturamento_pendente_processamento] ADD  DEFAULT ('Em processamento') FOR [Status]
GO
ALTER TABLE [dbo].[tb_faturamento_pendente_processamento] ADD  DEFAULT (getdate()) FOR [DataCadastro]
GO
ALTER TABLE [dbo].[tb_feriados] ADD  DEFAULT ((1)) FOR [tfd_in_ativo]
GO
ALTER TABLE [dbo].[tb_feriados] ADD  DEFAULT ((0)) FOR [tfd_in_excluido]
GO
ALTER TABLE [dbo].[tb_fila_emails] ADD  DEFAULT ('boas vindas') FOR [fle_ds_tipo_email]
GO
ALTER TABLE [dbo].[tb_fila_emails] ADD  DEFAULT ((0)) FOR [fle_cd_status_processamento]
GO
ALTER TABLE [dbo].[tb_fin_base_frete_adicional] ADD  DEFAULT (sysutcdatetime()) FOR [ValidFrom]
GO
ALTER TABLE [dbo].[tb_fin_base_frete_adicional] ADD  DEFAULT (CONVERT([datetime2](7),'9999-12-31 23:59:59.9999999')) FOR [ValidTo]
GO
ALTER TABLE [dbo].[tb_fin_base_frete_adicional_motorista] ADD  DEFAULT (sysutcdatetime()) FOR [ValidFrom]
GO
ALTER TABLE [dbo].[tb_fin_base_frete_adicional_motorista] ADD  DEFAULT (CONVERT([datetime2](7),'9999-12-31 23:59:59.9999999')) FOR [ValidTo]
GO
ALTER TABLE [dbo].[tb_fin_base_frete_motorista] ADD  DEFAULT (sysutcdatetime()) FOR [ValidFrom]
GO
ALTER TABLE [dbo].[tb_fin_base_frete_motorista] ADD  DEFAULT (CONVERT([datetime2](7),'9999-12-31 23:59:59.9999999')) FOR [ValidTo]
GO
ALTER TABLE [dbo].[tb_fin_base_frete_transportadora] ADD  DEFAULT (sysutcdatetime()) FOR [ValidFrom]
GO
ALTER TABLE [dbo].[tb_fin_base_frete_transportadora] ADD  DEFAULT (CONVERT([datetime2](7),'9999-12-31 23:59:59.9999999')) FOR [ValidTo]
GO
ALTER TABLE [dbo].[tb_fin_cadastro_impostos] ADD  CONSTRAINT [DF_tb_fin_cadastro_impostos_in_ativo]  DEFAULT ((1)) FOR [cdi_in_ativo]
GO
ALTER TABLE [dbo].[tb_fin_cadastro_impostos] ADD  CONSTRAINT [DF_tb_fin_cadastro_impostos_dh_criacao]  DEFAULT (sysutcdatetime()) FOR [cdi_dh_criacao]
GO
ALTER TABLE [dbo].[tb_fin_Cidades_DePara] ADD  DEFAULT (getdate()) FOR [cid_dh_criacao]
GO
ALTER TABLE [dbo].[tb_fin_dados_bancarios] ADD  DEFAULT (getdate()) FOR [cdb_dh_reference_date]
GO
ALTER TABLE [dbo].[tb_fin_faturas] ADD  DEFAULT (getdate()) FOR [fat_dh_criacao]
GO
ALTER TABLE [dbo].[tb_fin_regras_financeiro] ADD  DEFAULT ((1)) FOR [rlf_int_ativo]
GO
ALTER TABLE [dbo].[tb_fin_regras_financeiro] ADD  DEFAULT (getdate()) FOR [rlf_dt_cadastro]
GO
ALTER TABLE [dbo].[tb_fin_salarios_profissionais] ADD  DEFAULT ((0)) FOR [tsp_in_considera_sabado]
GO
ALTER TABLE [dbo].[tb_fin_salarios_profissionais] ADD  DEFAULT ((0)) FOR [tsp_in_considera_domingos_feriados]
GO
ALTER TABLE [dbo].[tb_fin_salarios_profissionais] ADD  DEFAULT (getdate()) FOR [tsp_dh_criacao]
GO
ALTER TABLE [dbo].[tb_fin_salarios_profissionais] ADD  DEFAULT ((1)) FOR [tsp_in_ativo]
GO
ALTER TABLE [dbo].[tb_fin_salarios_profissionais] ADD  DEFAULT ((0)) FOR [tsp_in_excluido]
GO
ALTER TABLE [dbo].[tb_formularios] ADD  CONSTRAINT [frm_in_onboarding_default]  DEFAULT ((0)) FOR [frm_in_onboarding]
GO
ALTER TABLE [dbo].[tb_formularios] ADD  DEFAULT ((0)) FOR [frm_in_checklist]
GO
ALTER TABLE [dbo].[tb_formularios] ADD  DEFAULT ((0)) FOR [frm_in_update_usr]
GO
ALTER TABLE [dbo].[tb_grupo_acesso] ADD  CONSTRAINT [DF_tb_grupo_acesso_gpa_in_compartilhado]  DEFAULT ((0)) FOR [gpa_in_compartilhado]
GO
ALTER TABLE [dbo].[tb_historico_alugueis] ADD  DEFAULT ((0)) FOR [his_cd_motorista]
GO
ALTER TABLE [dbo].[tb_historico_alugueis] ADD  DEFAULT ((0)) FOR [his_cd_veiculo]
GO
ALTER TABLE [dbo].[tb_historico_alugueis_geral] ADD  DEFAULT (getdate()) FOR [his_dh_criacao]
GO
ALTER TABLE [dbo].[tb_historico_alugueis_geral] ADD  DEFAULT (getdate()) FOR [his_dh_atualizacao]
GO
ALTER TABLE [dbo].[tb_historico_alugueis_geral] ADD  DEFAULT ((0)) FOR [his_cd_historico_relacao]
GO
ALTER TABLE [dbo].[tb_imp_grupo] ADD  CONSTRAINT [DF_tb_imp_grupo_ativo]  DEFAULT ((1)) FOR [grp_in_ativo]
GO
ALTER TABLE [dbo].[tb_imp_grupo] ADD  CONSTRAINT [DF_tb_imp_grupo_criacao]  DEFAULT (getdate()) FOR [grp_dh_criacao]
GO
ALTER TABLE [dbo].[tb_imp_importador] ADD  CONSTRAINT [DF_tb_imp_importador_ext]  DEFAULT ('.xlsx,.xls,.csv') FOR [imp_ds_extensoes_permitidas]
GO
ALTER TABLE [dbo].[tb_imp_importador] ADD  CONSTRAINT [DF_tb_imp_importador_tam]  DEFAULT ((10)) FOR [imp_nu_tamanho_maximo_mb]
GO
ALTER TABLE [dbo].[tb_imp_importador] ADD  CONSTRAINT [DF_tb_imp_importador_script_disp]  DEFAULT ((0)) FOR [imp_in_script_disponivel]
GO
ALTER TABLE [dbo].[tb_imp_importador] ADD  CONSTRAINT [DF_tb_imp_importador_ativo]  DEFAULT ((1)) FOR [imp_in_ativo]
GO
ALTER TABLE [dbo].[tb_imp_importador] ADD  CONSTRAINT [DF_tb_imp_importador_criacao]  DEFAULT (getdate()) FOR [imp_dh_criacao]
GO
ALTER TABLE [dbo].[tb_imp_importador_coluna] ADD  CONSTRAINT [DF_tb_imp_importador_coluna_ordem]  DEFAULT ((0)) FOR [imc_nu_ordem]
GO
ALTER TABLE [dbo].[tb_imp_importador_coluna] ADD  CONSTRAINT [DF_tb_imp_importador_coluna_obrig]  DEFAULT ((1)) FOR [imc_in_obrigatoria]
GO
ALTER TABLE [dbo].[tb_imp_importador_coluna] ADD  CONSTRAINT [DF_tb_imp_importador_coluna_nulo]  DEFAULT ((0)) FOR [imc_in_permite_nulo]
GO
ALTER TABLE [dbo].[tb_imp_log] ADD  CONSTRAINT [DF_tb_imp_log_status]  DEFAULT ((1)) FOR [ist_cd_status]
GO
ALTER TABLE [dbo].[tb_imp_log] ADD  CONSTRAINT [DF_tb_imp_log_inicio]  DEFAULT (getdate()) FOR [ilg_dh_inicio]
GO
ALTER TABLE [dbo].[tb_imp_log_coluna_erro] ADD  CONSTRAINT [DF_tb_imp_log_coluna_erro_criacao]  DEFAULT (getdate()) FOR [ice_dh_criacao]
GO
ALTER TABLE [dbo].[tb_imp_log_edicao] ADD  CONSTRAINT [DF_tb_imp_log_edicao_criacao]  DEFAULT (getdate()) FOR [ied_dh_criacao]
GO
ALTER TABLE [dbo].[tb_imp_log_execucao_script] ADD  CONSTRAINT [DF_tb_imp_log_exec_script_inicio]  DEFAULT (getdate()) FOR [ies_dh_inicio]
GO
ALTER TABLE [dbo].[tb_indisponibilidade_motorista] ADD  DEFAULT (getdate()) FOR [idp_dh_registro]
GO
ALTER TABLE [dbo].[tb_indisponibilidade_motorista] ADD  DEFAULT ((0)) FOR [idp_in_cancelado]
GO
ALTER TABLE [dbo].[tb_indisponibilidade_motorista] ADD  DEFAULT (getdate()) FOR [idp_dh_criacao]
GO
ALTER TABLE [dbo].[tb_integracao_flex_eventos] ADD  DEFAULT (NULL) FOR [iev_dh_data_hora_evento_utc]
GO
ALTER TABLE [dbo].[tb_lancamentos_manuais] ADD  DEFAULT ((1)) FOR [tlm_in_ativo]
GO
ALTER TABLE [dbo].[tb_lancamentos_manuais] ADD  DEFAULT ((0)) FOR [tlm_in_excluido]
GO
ALTER TABLE [dbo].[tb_lancamentos_manuais] ADD  DEFAULT (sysutcdatetime()) FOR [ValidFrom]
GO
ALTER TABLE [dbo].[tb_lancamentos_manuais] ADD  DEFAULT (CONVERT([datetime2](7),'9999-12-31 23:59:59.9999999')) FOR [ValidTo]
GO
ALTER TABLE [dbo].[tb_lancamentos_manuais_importacao_log] ADD  DEFAULT (getdate()) FOR [lmi_dh_registro]
GO
ALTER TABLE [dbo].[tb_layout_pagto_importacao] ADD  DEFAULT ((0)) FOR [Valor_Variavel]
GO
ALTER TABLE [dbo].[tb_layout_pagto_importacao] ADD  DEFAULT ((0)) FOR [Valor_Fixo]
GO
ALTER TABLE [dbo].[tb_layout_pagto_importacao] ADD  DEFAULT ((0)) FOR [KM_Excedente]
GO
ALTER TABLE [dbo].[tb_layout_pagto_importacao] ADD  DEFAULT ((0)) FOR [Ajudante]
GO
ALTER TABLE [dbo].[tb_layout_pagto_importacao] ADD  DEFAULT ((0)) FOR [KM_Rodados]
GO
ALTER TABLE [dbo].[tb_layout_pagto_importacao] ADD  DEFAULT ((0)) FOR [Valor_Total]
GO
ALTER TABLE [dbo].[tb_layout_pagto_importacao] ADD  DEFAULT ((0)) FOR [Falha_de_entrega]
GO
ALTER TABLE [dbo].[tb_layout_pagto_importacao] ADD  DEFAULT ((0)) FOR [SPR]
GO
ALTER TABLE [dbo].[tb_layout_pagto_importacao] ADD  DEFAULT ((0)) FOR [Pontos]
GO
ALTER TABLE [dbo].[tb_layout_pagto_importacao] ADD  DEFAULT ((0)) FOR [Paradas]
GO
ALTER TABLE [dbo].[tb_log_aprovacao_motorista] ADD  DEFAULT (getdate()) FOR [lam_dh_aprovacao]
GO
ALTER TABLE [dbo].[tb_log_automatizacao_worker] ADD  DEFAULT (getdate()) FOR [DataHora]
GO
ALTER TABLE [dbo].[tb_log_importacao_lancamentos_manuais] ADD  DEFAULT ((0)) FOR [lim_qt_total_registros]
GO
ALTER TABLE [dbo].[tb_log_importacao_lancamentos_manuais] ADD  DEFAULT ((0)) FOR [lim_qt_registros_processados]
GO
ALTER TABLE [dbo].[tb_log_importacao_lancamentos_manuais] ADD  DEFAULT ((0)) FOR [lim_qt_registros_com_erro]
GO
ALTER TABLE [dbo].[tb_log_importacao_lancamentos_manuais] ADD  DEFAULT (getdate()) FOR [lim_dh_criacao]
GO
ALTER TABLE [dbo].[tb_log_importacao_lancamentos_manuais] ADD  DEFAULT (getdate()) FOR [lim_dh_modificacao]
GO
ALTER TABLE [dbo].[tb_log_importacao_lancamentos_manuais] ADD  DEFAULT ((0)) FOR [lim_in_excluido]
GO
ALTER TABLE [dbo].[tb_log_importacao_lancamentos_manuais] ADD  DEFAULT ((1)) FOR [lim_in_ativo]
GO
ALTER TABLE [dbo].[tb_log_importacao_lancamentos_manuais_resultado] ADD  DEFAULT (getdate()) FOR [lir_dh_criacao]
GO
ALTER TABLE [dbo].[tb_logistics_fat_motoristas_faixa] ADD  DEFAULT ((0)) FOR [lfm_in_excluido]
GO
ALTER TABLE [dbo].[tb_map_formulario_usuario] ADD  DEFAULT (getdate()) FOR [fru_dh_criacao]
GO
ALTER TABLE [dbo].[tb_map_formulario_usuario] ADD  DEFAULT ((1)) FOR [fru_in_ativo]
GO
ALTER TABLE [dbo].[tb_mdfe_log] ADD  CONSTRAINT [DF_tb_mdfe_log_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[tb_mdfe_log] ADD  CONSTRAINT [DF_tb_mdfe_log_DataCriacao]  DEFAULT (getdate()) FOR [DataCriacao]
GO
ALTER TABLE [dbo].[tb_mdfe_log] ADD  CONSTRAINT [DF_tb_mdfe_log_Nivel]  DEFAULT ('ERROR') FOR [Nivel]
GO
ALTER TABLE [dbo].[tb_ml_aprovacao_usuario] ADD  DEFAULT ((0)) FOR [mau_in_habilitado]
GO
ALTER TABLE [dbo].[tb_ml_aprovacao_usuario] ADD  DEFAULT ('Em análise') FOR [mau_ds_status]
GO
ALTER TABLE [dbo].[tb_ml_aprovacao_usuario] ADD  DEFAULT ((1)) FOR [mau_in_ativo]
GO
ALTER TABLE [dbo].[tb_ml_aprovacao_usuario] ADD  DEFAULT ((0)) FOR [mau_in_excluido]
GO
ALTER TABLE [dbo].[tb_ml_aprovacao_usuario] ADD  DEFAULT ((0)) FOR [mau_in_reativacao]
GO
ALTER TABLE [dbo].[tb_ml_hist_insucesso] ADD  DEFAULT (getdate()) FOR [DataAtualizacao]
GO
ALTER TABLE [dbo].[tb_ml_hist_insucesso] ADD  DEFAULT ((0)) FOR [Revertido]
GO
ALTER TABLE [dbo].[tb_ml_hist_insucesso] ADD  DEFAULT ((0)) FOR [RevertidoOutraRota]
GO
ALTER TABLE [dbo].[tb_ml_mo_rotas] ADD  CONSTRAINT [DF_tb_ml_mo_rotas_Excluido]  DEFAULT ((0)) FOR [Excluido]
GO
ALTER TABLE [dbo].[tb_ml_pnr_tela] ADD  DEFAULT (sysdatetime()) FOR [dt_criacao]
GO
ALTER TABLE [dbo].[tb_ml_pnr_tela] ADD  DEFAULT (suser_sname()) FOR [usuario_criacao]
GO
ALTER TABLE [dbo].[tb_ml_pnr_tela_log] ADD  DEFAULT (sysdatetime()) FOR [data_operacao]
GO
ALTER TABLE [dbo].[tb_ml_pnr_tela_log] ADD  DEFAULT (suser_sname()) FOR [usuario_operacao]
GO
ALTER TABLE [dbo].[tb_ml_processamento_km_rotas] ADD  DEFAULT (newid()) FOR [idRotaGuid]
GO
ALTER TABLE [dbo].[tb_ml_processamento_km_rotas] ADD  DEFAULT ((0)) FOR [processamento]
GO
ALTER TABLE [dbo].[tb_ml_processamento_km_rotas] ADD  DEFAULT (getdate()) FOR [dateCreated]
GO
ALTER TABLE [dbo].[tb_ml_rotas] ADD  DEFAULT ((0)) FOR [QuantidadePontos]
GO
ALTER TABLE [dbo].[tb_ml_rotas] ADD  DEFAULT ((0)) FOR [QuantidadeParadas]
GO
ALTER TABLE [dbo].[tb_ml_rotas] ADD  DEFAULT ((0)) FOR [QuantidadeReclamacoes]
GO
ALTER TABLE [dbo].[tb_ml_rotas] ADD  DEFAULT ((0)) FOR [KmColetado]
GO
ALTER TABLE [dbo].[tb_ml_rotas] ADD  DEFAULT ((0)) FOR [IdTrevo]
GO
ALTER TABLE [dbo].[tb_ml_status_entrega_traducao] ADD  DEFAULT (sysdatetime()) FOR [DataCriacao]
GO
ALTER TABLE [dbo].[tb_motorista] ADD  DEFAULT ((1)) FOR [mot_fl_status_aluguel]
GO
ALTER TABLE [dbo].[tb_motorista] ADD  DEFAULT ((0)) FOR [mot_pag_confirma_conta]
GO
ALTER TABLE [dbo].[tb_motorista] ADD  DEFAULT (getdate()) FOR [ValidFrom]
GO
ALTER TABLE [dbo].[tb_motorista] ADD  DEFAULT (CONVERT([datetime2](7),'9999-12-31 23:59:59.9999999')) FOR [ValidTo]
GO
ALTER TABLE [dbo].[tb_motorista] ADD  DEFAULT (suser_sname()) FOR [mot_usr_criacao]
GO
ALTER TABLE [dbo].[tb_motorista] ADD  DEFAULT (getdate()) FOR [mot_dh_criacao]
GO
ALTER TABLE [dbo].[tb_mtr_webhook] ADD  DEFAULT (getdate()) FOR [createdAt]
GO
ALTER TABLE [dbo].[tb_ouvidoria] ADD  DEFAULT ((0)) FOR [Procedente]
GO
ALTER TABLE [dbo].[tb_ouvidoria_respostas] ADD  DEFAULT (getdate()) FOR [DataHoraCriacao]
GO
ALTER TABLE [dbo].[tb_ouvidoria_setores] ADD  DEFAULT ((1)) FOR [Ativo]
GO
ALTER TABLE [dbo].[tb_pac_sinistros] ADD  DEFAULT ((1)) FOR [pac_in_ativo]
GO
ALTER TABLE [dbo].[tb_pac_sinistros] ADD  DEFAULT ((0)) FOR [pac_in_excluido]
GO
ALTER TABLE [dbo].[tb_pag_espelhos] ADD  DEFAULT ((0)) FOR [mtn_vl_desconto]
GO
ALTER TABLE [dbo].[tb_pag_espelhos] ADD  DEFAULT (sysutcdatetime()) FOR [ValidFrom]
GO
ALTER TABLE [dbo].[tb_pag_espelhos] ADD  DEFAULT (CONVERT([datetime2](7),'9999-12-31 23:59:59.9999999')) FOR [ValidTo]
GO
ALTER TABLE [dbo].[tb_pag_espelhos] ADD  CONSTRAINT [DF_tb_pag_espelhos_mtn_in_prevista_manual]  DEFAULT ((0)) FOR [mtn_in_prevista_manual]
GO
ALTER TABLE [dbo].[tb_pag_espelhos] ADD  DEFAULT ((0)) FOR [mtn_in_numero_tentativas]
GO
ALTER TABLE [dbo].[tb_pag_espelhos] ADD  CONSTRAINT [DF_pag_espelhos_validacao_monitoramento]  DEFAULT ((0)) FOR [mtn_in_validacao_monitoramento]
GO
ALTER TABLE [dbo].[tb_pag_espelhos_logs] ADD  DEFAULT (getdate()) FOR [lsm_dt_data_log]
GO
ALTER TABLE [dbo].[tb_pag_espelhos_nfse] ADD  DEFAULT (sysutcdatetime()) FOR [ValidFrom]
GO
ALTER TABLE [dbo].[tb_pag_espelhos_nfse] ADD  DEFAULT (CONVERT([datetime2](7),'9999-12-31 23:59:59.9999999')) FOR [ValidTo]
GO
ALTER TABLE [dbo].[tb_pag_integracao_bancos] ADD  DEFAULT (newid()) FOR [pib_ui_id]
GO
ALTER TABLE [dbo].[tb_pag_integracao_bancos] ADD  CONSTRAINT [DF_pib_nr_tentativas_comprovante]  DEFAULT ((0)) FOR [pib_nr_tentativas_comprovante]
GO
ALTER TABLE [dbo].[tb_pbi_mon_etapas] ADD  DEFAULT ((1)) FOR [etapa_ativo]
GO
ALTER TABLE [dbo].[tb_pbi_mon_etapas] ADD  DEFAULT (sysutcdatetime()) FOR [dh_inclusao]
GO
ALTER TABLE [dbo].[tb_pbi_mon_fluxos] ADD  DEFAULT ((1)) FOR [fluxo_ativo]
GO
ALTER TABLE [dbo].[tb_pbi_mon_fluxos] ADD  DEFAULT (sysutcdatetime()) FOR [dh_inclusao]
GO
ALTER TABLE [dbo].[tb_pbi_mon_processo] ADD  CONSTRAINT [DF_tb_pbi_mon_processo_in_origem_irisys_json]  DEFAULT ((0)) FOR [in_origem_irisys_json]
GO
ALTER TABLE [dbo].[tb_pbi_mon_processo] ADD  CONSTRAINT [DF_tb_pbi_mon_processo_nr_lag]  DEFAULT ((0)) FOR [nr_lag_dias_negocio]
GO
ALTER TABLE [dbo].[tb_pbi_mon_processo] ADD  CONSTRAINT [DF_tb_pbi_mon_processo_sla]  DEFAULT ((5)) FOR [sla_minutos]
GO
ALTER TABLE [dbo].[tb_pbi_mon_processo] ADD  CONSTRAINT [DF_tb_pbi_mon_processo_in_ativo]  DEFAULT ((1)) FOR [in_ativo]
GO
ALTER TABLE [dbo].[tb_pbi_mon_processo] ADD  CONSTRAINT [DF_tb_pbi_mon_processo_dh_inclusao]  DEFAULT (sysdatetime()) FOR [dh_inclusao]
GO
ALTER TABLE [dbo].[tb_pbi_mon_processo] ADD  CONSTRAINT [DF_tb_pbi_mon_processo_sla_label]  DEFAULT (N'5 minutos') FOR [sla_label]
GO
ALTER TABLE [dbo].[tb_pbi_mon_processo] ADD  CONSTRAINT [DF_tb_pbi_mon_processo_destino_regra]  DEFAULT (N'FRESHNESS') FOR [destino_regra]
GO
ALTER TABLE [dbo].[tb_pbi_mon_processo] ADD  CONSTRAINT [DF_tb_pbi_mon_processo_nr_tolerancia_fila]  DEFAULT ((0)) FOR [nr_tolerancia_fila]
GO
ALTER TABLE [dbo].[tb_pbi_mon_processo] ADD  CONSTRAINT [DF_tb_pbi_mon_processo_in_origem_obrigatoria]  DEFAULT ((1)) FOR [in_origem_obrigatoria]
GO
ALTER TABLE [dbo].[tb_pbi_mon_processo] ADD  CONSTRAINT [DF_tb_pbi_mon_processo_in_acao_habilitada]  DEFAULT ((0)) FOR [in_acao_habilitada]
GO
ALTER TABLE [dbo].[tb_pbi_mon_processo_acao_log] ADD  CONSTRAINT [DF_tb_pbi_mon_processo_acao_log_dh_execucao]  DEFAULT (sysdatetime()) FOR [dh_execucao]
GO
ALTER TABLE [dbo].[tb_periodos_espelhos_pagamento] ADD  DEFAULT (getdate()) FOR [pep_dh_criacao]
GO
ALTER TABLE [dbo].[tb_periodos_espelhos_pagamento] ADD  DEFAULT ((1)) FOR [pep_in_ativo]
GO
ALTER TABLE [dbo].[tb_periodos_espelhos_pagamento] ADD  DEFAULT ((0)) FOR [pep_in_excluido]
GO
ALTER TABLE [dbo].[tb_pgto_espelh_temp_raw] ADD  CONSTRAINT [DF_tb_pgto_espelh_temp_raw_dh_importacao]  DEFAULT (sysdatetime()) FOR [dh_importacao]
GO
ALTER TABLE [dbo].[tb_pgto_espelho_importacoes] ADD  DEFAULT (getdate()) FOR [pei_dt_envio]
GO
ALTER TABLE [dbo].[tb_pgto_espelho_importacoes] ADD  DEFAULT ((0)) FOR [pei_qt_total_linhas]
GO
ALTER TABLE [dbo].[tb_pgto_espelho_importacoes] ADD  DEFAULT ((0)) FOR [pei_qt_total_sucesso]
GO
ALTER TABLE [dbo].[tb_pgto_espelho_importacoes] ADD  DEFAULT ((0)) FOR [pei_qt_total_erro]
GO
ALTER TABLE [dbo].[tb_pgto_espelho_importacoes] ADD  DEFAULT (getdate()) FOR [pei_dh_criacao]
GO
ALTER TABLE [dbo].[tb_pgto_espelho_importacoes] ADD  DEFAULT ((0)) FOR [pei_in_excluido]
GO
ALTER TABLE [dbo].[tb_pgto_espelho_importacoes_detalhes] ADD  DEFAULT ('Aguardando') FOR [peid_ds_status]
GO
ALTER TABLE [dbo].[tb_pgto_espelho_importacoes_detalhes] ADD  DEFAULT ((0)) FOR [peid_qt_tentativas_insercao]
GO
ALTER TABLE [dbo].[tb_pgto_lancamento_desc_cartao_flex_frota] ADD  DEFAULT (getdate()) FOR [pcf_dh_criacao]
GO
ALTER TABLE [dbo].[tb_pgto_lancamento_desc_cartao_flex_frota] ADD  DEFAULT ((7)) FOR [pcf_cd_usr_criacao]
GO
ALTER TABLE [dbo].[tb_pgto_lancamento_desc_cartao_flex_frota] ADD  DEFAULT (getdate()) FOR [pcf_dh_modificacao]
GO
ALTER TABLE [dbo].[tb_pgto_lancamento_desc_cartao_flex_frota] ADD  DEFAULT ((7)) FOR [pcf_cd_usr_modificacao]
GO
ALTER TABLE [dbo].[tb_pgto_lancamento_desc_cartao_flex_frota] ADD  DEFAULT ((1)) FOR [pcf_in_ativo]
GO
ALTER TABLE [dbo].[tb_pgto_lancamento_desc_cartao_flex_frota] ADD  DEFAULT ((0)) FOR [pcf_in_excluido]
GO
ALTER TABLE [dbo].[tb_pgto_periodo] ADD  DEFAULT (getdate()) FOR [pgp_dh_criacao]
GO
ALTER TABLE [dbo].[tb_pgto_periodo] ADD  DEFAULT ((1)) FOR [pgp_in_ativo]
GO
ALTER TABLE [dbo].[tb_pgto_periodo] ADD  DEFAULT ((0)) FOR [pgp_in_excluido]
GO
ALTER TABLE [dbo].[tb_pgto_periodo] ADD  DEFAULT (sysutcdatetime()) FOR [ValidFrom]
GO
ALTER TABLE [dbo].[tb_pgto_periodo] ADD  DEFAULT (CONVERT([datetime2](7),'9999-12-31 23:59:59.9999999')) FOR [ValidTo]
GO
ALTER TABLE [dbo].[tb_pgto_periodo_rota] ADD  DEFAULT (getdate()) FOR [ppr_dh_criacao]
GO
ALTER TABLE [dbo].[tb_pgto_periodo_rota] ADD  DEFAULT ((1)) FOR [ppr_in_ativo]
GO
ALTER TABLE [dbo].[tb_pgto_periodo_rota] ADD  DEFAULT ((0)) FOR [ppr_in_excluido]
GO
ALTER TABLE [dbo].[tb_pgto_periodo_rota] ADD  DEFAULT ((0)) FOR [ppr_fl_desconto]
GO
ALTER TABLE [dbo].[tb_pgto_periodo_rota] ADD  DEFAULT (sysutcdatetime()) FOR [ValidFrom]
GO
ALTER TABLE [dbo].[tb_pgto_periodo_rota] ADD  DEFAULT (CONVERT([datetime2](7),'9999-12-31 23:59:59.9999999')) FOR [ValidTo]
GO
ALTER TABLE [dbo].[tb_pgto_periodo_rota] ADD  DEFAULT ((1)) FOR [ppr_in_calcular_adicional]
GO
ALTER TABLE [dbo].[tb_pgto_periodo_rota] ADD  DEFAULT ((0)) FOR [ppr_in_zerar_rota]
GO
ALTER TABLE [dbo].[tb_rcto_periodo] ADD  DEFAULT (getdate()) FOR [rcb_dh_criacao]
GO
ALTER TABLE [dbo].[tb_rcto_periodo] ADD  DEFAULT ((1)) FOR [rcb_in_ativo]
GO
ALTER TABLE [dbo].[tb_rcto_periodo] ADD  DEFAULT ((0)) FOR [rcb_in_excluido]
GO
ALTER TABLE [dbo].[tb_rcto_periodo_rota] ADD  DEFAULT (getdate()) FOR [rcp_dh_criacao]
GO
ALTER TABLE [dbo].[tb_rcto_periodo_rota] ADD  DEFAULT ((1)) FOR [rcp_in_ativo]
GO
ALTER TABLE [dbo].[tb_rcto_periodo_rota] ADD  DEFAULT ((0)) FOR [rcp_in_excluido]
GO
ALTER TABLE [dbo].[tb_registro_gps] ADD  CONSTRAINT [DF_tb_registro_gps_in_coordenada_fantasma]  DEFAULT ((0)) FOR [rgp_in_coordenada_fantasma]
GO
ALTER TABLE [dbo].[tb_regra_sla] ADD  DEFAULT ((2)) FOR [dias_sla]
GO
ALTER TABLE [dbo].[tb_regra_sla] ADD  DEFAULT (getdate()) FOR [data_edicao]
GO
ALTER TABLE [dbo].[tb_responsavel] ADD  CONSTRAINT [DF_tb_responsavel_in_ativo]  DEFAULT ((0)) FOR [Status]
GO
ALTER TABLE [dbo].[tb_rotas_dados_transportadora] ADD  DEFAULT (getdate()) FOR [rdt_dh_criacao]
GO
ALTER TABLE [dbo].[tb_rotas_dados_transportadora] ADD  DEFAULT ((1)) FOR [rdt_in_ativo]
GO
ALTER TABLE [dbo].[tb_rotas_dados_transportadora] ADD  DEFAULT ((0)) FOR [rdt_in_excluido]
GO
ALTER TABLE [dbo].[tb_setor] ADD  CONSTRAINT [df_tb_setor_ativo]  DEFAULT ((1)) FOR [set_in_ativo]
GO
ALTER TABLE [dbo].[tb_sin_sinistro] ADD  CONSTRAINT [DF__tb_sin_si__sin_i__0DF9F0CA]  DEFAULT ((0)) FOR [sin_in_possui_ajudante]
GO
ALTER TABLE [dbo].[tb_sin_sinistro] ADD  CONSTRAINT [DF__tb_sin_si__sin_d__0EEE1503]  DEFAULT (getdate()) FOR [sin_dt_data]
GO
ALTER TABLE [dbo].[tb_sin_sinistro] ADD  CONSTRAINT [DF__tb_sin_si__sin_i__0FE2393C]  DEFAULT ((1)) FOR [sin_in_ativo]
GO
ALTER TABLE [dbo].[tb_sin_sinistro] ADD  CONSTRAINT [DF__tb_sin_si__sin_i__10D65D75]  DEFAULT ((0)) FOR [sin_in_excluido]
GO
ALTER TABLE [dbo].[tb_sin_sinistro] ADD  CONSTRAINT [DF_sin_inv_monitoramento]  DEFAULT ((0)) FOR [sin_in_monitoramento_ativo]
GO
ALTER TABLE [dbo].[tb_sin_sinistro] ADD  CONSTRAINT [DF_sin_inv_rota_risco]  DEFAULT ((0)) FOR [sin_in_rota_risco]
GO
ALTER TABLE [dbo].[tb_sin_sinistro] ADD  CONSTRAINT [DF_sin_inv_prioridade]  DEFAULT ((0)) FOR [sin_in_prioridade_aplicada]
GO
ALTER TABLE [dbo].[tb_sin_sinistro] ADD  CONSTRAINT [DF_sin_inv_veic_inativo]  DEFAULT ((0)) FOR [sin_in_veiculo_inativo]
GO
ALTER TABLE [dbo].[tb_sin_sinistro] ADD  CONSTRAINT [DF_sin_inv_veic_sem_ativ]  DEFAULT ((0)) FOR [sin_in_veiculo_sem_atividade]
GO
ALTER TABLE [dbo].[tb_spe_export_rotas] ADD  CONSTRAINT [df_spe_export_rotas_processado]  DEFAULT ((0)) FOR [ser_in_processado]
GO
ALTER TABLE [dbo].[tb_spe_motoristas] ADD  DEFAULT ((1)) FOR [Ativo]
GO
ALTER TABLE [dbo].[tb_spe_pacotes_FM] ADD  DEFAULT ((1)) FOR [UltimoRegistro]
GO
ALTER TABLE [dbo].[tb_spe_pacotes_FM] ADD  DEFAULT ((0)) FOR [Excluido]
GO
ALTER TABLE [dbo].[tb_spe_pacotes_FM] ADD  DEFAULT (getdate()) FOR [DataInclusao]
GO
ALTER TABLE [dbo].[tb_spe_pacotes_v4] ADD  DEFAULT ((0)) FOR [Excluido]
GO
ALTER TABLE [dbo].[tb_spe_processamento_km_rotas] ADD  DEFAULT (newid()) FOR [idRotaGuid]
GO
ALTER TABLE [dbo].[tb_spe_processamento_km_rotas] ADD  DEFAULT ((0)) FOR [processamento]
GO
ALTER TABLE [dbo].[tb_spe_processamento_km_rotas] ADD  DEFAULT (getdate()) FOR [dateCreated]
GO
ALTER TABLE [dbo].[tb_spe_return_order] ADD  CONSTRAINT [DF_tb_spe_return_order_DataImportacao]  DEFAULT (sysdatetime()) FOR [DataImportacao]
GO
ALTER TABLE [dbo].[tb_spe_return_order_import_log] ADD  CONSTRAINT [DF_tb_spe_return_order_import_log_LogDate]  DEFAULT (sysdatetime()) FOR [LogDate]
GO
ALTER TABLE [dbo].[tb_spe_return_order_upload_error_log] ADD  CONSTRAINT [DF_tb_spe_return_order_upload_error_log_LogDate]  DEFAULT (sysdatetime()) FOR [LogDate]
GO
ALTER TABLE [dbo].[tb_spe_rotas] ADD  DEFAULT ((0)) FOR [TotalPacotes]
GO
ALTER TABLE [dbo].[tb_spe_rotas] ADD  DEFAULT ((0)) FOR [PacotesEntregues]
GO
ALTER TABLE [dbo].[tb_spe_rotas] ADD  DEFAULT ((0)) FOR [PacotesNaoEntregue]
GO
ALTER TABLE [dbo].[tb_spe_rotas] ADD  DEFAULT ((0)) FOR [PacotesPendentes]
GO
ALTER TABLE [dbo].[tb_spe_rotas_prefatura] ADD  CONSTRAINT [DF_tb_spe_rotas_prefatura_DataAtualizacao]  DEFAULT (getdate()) FOR [DataAtualizacao]
GO
ALTER TABLE [dbo].[tb_spe_sla_stuck] ADD  DEFAULT (getdate()) FOR [DataImportacao]
GO
ALTER TABLE [dbo].[tb_spe_webhook_dev] ADD  DEFAULT (getdate()) FOR [createdAt]
GO
ALTER TABLE [dbo].[tb_spe_webhook_dev] ADD  DEFAULT ((0)) FOR [processingStatus]
GO
ALTER TABLE [dbo].[tb_stg_dra_historico_rotas_lh] ADD  CONSTRAINT [DF_tb_stg_dra_historico_rotas_lh_dh_inclusao]  DEFAULT (sysdatetime()) FOR [stg_dh_inclusao]
GO
ALTER TABLE [dbo].[tb_stg_dra_historico_rotas_lh] ADD  CONSTRAINT [DF_tb_stg_dra_historico_rotas_lh_in_processado]  DEFAULT ((0)) FOR [stg_in_processado]
GO
ALTER TABLE [dbo].[tb_stress_test] ADD  CONSTRAINT [df_stress_test]  DEFAULT (getdate()) FOR [datahora]
GO
ALTER TABLE [dbo].[tb_termos_aceites] ADD  DEFAULT ((1)) FOR [tra_in_ativo]
GO
ALTER TABLE [dbo].[tb_termos_aceites] ADD  DEFAULT ((0)) FOR [tra_in_excluido]
GO
ALTER TABLE [dbo].[tb_termos_aceites] ADD  DEFAULT ((0)) FOR [tra_in_home_app]
GO
ALTER TABLE [dbo].[tb_termos_aceites] ADD  DEFAULT ((0)) FOR [tra_in_home_web]
GO
ALTER TABLE [dbo].[tb_termos_aceites_confirmados] ADD  DEFAULT ((1)) FOR [tac_in_ativo]
GO
ALTER TABLE [dbo].[tb_termos_aceites_confirmados] ADD  DEFAULT ((0)) FOR [tac_in_excluido]
GO
ALTER TABLE [dbo].[tb_termos_aceites_tipo_contrato] ADD  DEFAULT ((1)) FOR [tat_in_ativo]
GO
ALTER TABLE [dbo].[tb_termos_aceites_tipo_contrato] ADD  DEFAULT ((0)) FOR [tat_in_excluido]
GO
ALTER TABLE [dbo].[tb_tipo_contrato] ADD  DEFAULT ((0)) FOR [ttc_in_motoristas_vinculados]
GO
ALTER TABLE [dbo].[tb_tipo_contrato] ADD  DEFAULT ((0)) FOR [ttc_in_veiculos_vinculados]
GO
ALTER TABLE [dbo].[tb_tipo_contrato] ADD  DEFAULT ((1)) FOR [ttc_in_ativo]
GO
ALTER TABLE [dbo].[tb_tipo_contrato] ADD  DEFAULT ((0)) FOR [ttc_in_excluido]
GO
ALTER TABLE [dbo].[tb_tipo_contrato] ADD  DEFAULT ((0)) FOR [ttc_in_administrativo]
GO
ALTER TABLE [dbo].[tb_tipo_frota] ADD  DEFAULT ((0)) FOR [tf_fl_excluido]
GO
ALTER TABLE [dbo].[tb_tipo_frota] ADD  DEFAULT (getdate()) FOR [tf_dh_criacao]
GO
ALTER TABLE [dbo].[tb_tipo_frota] ADD  DEFAULT (getdate()) FOR [tf_dh_atualizacao]
GO
ALTER TABLE [dbo].[tb_tipo_veiculo] ADD  DEFAULT ((0)) FOR [tv_fl_excluido]
GO
ALTER TABLE [dbo].[tb_tipo_veiculo] ADD  DEFAULT (getdate()) FOR [tv_dh_criacao]
GO
ALTER TABLE [dbo].[tb_tipo_veiculo] ADD  DEFAULT (getdate()) FOR [tv_dh_atualizacao]
GO
ALTER TABLE [dbo].[tb_tipos_lancamentos_manuais] ADD  DEFAULT ((1)) FOR [plm_in_ativo]
GO
ALTER TABLE [dbo].[tb_tipos_lancamentos_manuais] ADD  DEFAULT ((0)) FOR [plm_in_calculo_desconto]
GO
ALTER TABLE [dbo].[tb_tr_categoria_cnh] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[tb_tr_cidade_estrangeira] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[tb_tr_cidades] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[tb_tr_cor] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[tb_tr_estado] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[tb_tr_estado_estrangeiro] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[tb_tr_marca] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[tb_tr_mercadoria] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[tb_tr_modelo] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[tb_tr_pais] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[tb_tr_parentesco_referencia_pessoal] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[tb_tr_rastreador] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[tb_tr_tipo_motorista] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[tb_tr_tipo_nacionalidade] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[tb_tr_tipo_referencia_comercial] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[tb_tr_tipo_veiculo] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[tb_tratativas_entregas] ADD  DEFAULT (getdate()) FOR [DataCriacao]
GO
ALTER TABLE [dbo].[tb_trg_CIOT] ADD  DEFAULT ((0)) FOR [StatusIntegracao]
GO
ALTER TABLE [dbo].[tb_trg_CIOT] ADD  DEFAULT ((0)) FOR [StatusProcesso]
GO
ALTER TABLE [dbo].[tb_trg_CIOT] ADD  DEFAULT ((0)) FOR [Excluido]
GO
ALTER TABLE [dbo].[tb_trg_CIOT] ADD  DEFAULT ((0.0)) FOR [ValorBrutoEspelhoPagamento]
GO
ALTER TABLE [dbo].[tb_trg_CIOT] ADD  DEFAULT ((0)) FOR [ValorFreteFinal]
GO
ALTER TABLE [dbo].[tb_trg_CIOTHistorico] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[tb_usuario] ADD  DEFAULT ((0)) FOR [usr_in_token_mobile_tentativas]
GO
ALTER TABLE [dbo].[tb_usuario] ADD  DEFAULT ((0)) FOR [usr_in_registro_gps]
GO
ALTER TABLE [dbo].[tb_usuario] ADD  DEFAULT ((1)) FOR [usr_in_fat_motorista_valor_app]
GO
ALTER TABLE [dbo].[tb_usuario] ADD  DEFAULT ((0)) FOR [usr_reset_token]
GO
ALTER TABLE [dbo].[tb_usuario] ADD  CONSTRAINT [DF__tb_usuari__Valid__16CF2DED]  DEFAULT (sysutcdatetime()) FOR [ValidFrom]
GO
ALTER TABLE [dbo].[tb_usuario] ADD  DEFAULT (CONVERT([datetime2](7),'9999-12-31 23:59:59.9999999')) FOR [ValidTo]
GO
ALTER TABLE [dbo].[tb_usuario] ADD  DEFAULT ('') FOR [usr_chat_senha_temporaria]
GO
ALTER TABLE [dbo].[tb_usuario] ADD  DEFAULT ((0)) FOR [usr_in_fat_multiplas_notas_app]
GO
ALTER TABLE [dbo].[tb_usuario_cadastro_app] ADD  DEFAULT ((0)) FOR [ucp_in_aprovado]
GO
ALTER TABLE [dbo].[tb_usuario_cadastro_app] ADD  DEFAULT ((0)) FOR [ucp_in_excluido]
GO
ALTER TABLE [dbo].[tb_veiculos] ADD  CONSTRAINT [DF__tb_veicul__vei_i__40257DE4]  DEFAULT ((1)) FOR [vei_in_ativo]
GO
ALTER TABLE [dbo].[tb_veiculos] ADD  CONSTRAINT [DF__tb_veicul__vei_i__4119A21D]  DEFAULT ((0)) FOR [vei_in_excluido]
GO
ALTER TABLE [dbo].[tb_veiculos] ADD  DEFAULT ((0)) FOR [vei_alugar_veiculo]
GO
ALTER TABLE [dbo].[tb_veiculos] ADD  DEFAULT ((1)) FOR [vei_fl_status_aluguel]
GO
ALTER TABLE [dbo].[tb_veiculos_proprietarios] ADD  CONSTRAINT [DF_vep_dh_criacao]  DEFAULT (getdate()) FOR [vep_dh_criacao]
GO
ALTER TABLE [dbo].[override_tb_envio_relatios]  WITH CHECK ADD  CONSTRAINT [FK_dbo.override_tb_envio_relatios_dbo.override_tb_clientes_tb_clientes_cli_cd_codigo_cliente] FOREIGN KEY([tb_clientes_cli_cd_codigo_cliente])
REFERENCES [dbo].[override_tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[override_tb_envio_relatios] CHECK CONSTRAINT [FK_dbo.override_tb_envio_relatios_dbo.override_tb_clientes_tb_clientes_cli_cd_codigo_cliente]
GO
ALTER TABLE [dbo].[override_tb_envio_relatios]  WITH CHECK ADD  CONSTRAINT [FK_dbo.override_tb_envio_relatios_dbo.override_tb_relatorios_tb_relatorios_rel_cd_relatorio] FOREIGN KEY([tb_relatorios_rel_cd_relatorio])
REFERENCES [dbo].[override_tb_relatorios] ([rel_cd_relatorio])
GO
ALTER TABLE [dbo].[override_tb_envio_relatios] CHECK CONSTRAINT [FK_dbo.override_tb_envio_relatios_dbo.override_tb_relatorios_tb_relatorios_rel_cd_relatorio]
GO
ALTER TABLE [dbo].[tb_acao_gps]  WITH CHECK ADD  CONSTRAINT [fk_acao_gps_rgp_cd_usuario] FOREIGN KEY([agp_cd_usuario])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_acao_gps] CHECK CONSTRAINT [fk_acao_gps_rgp_cd_usuario]
GO
ALTER TABLE [dbo].[tb_acessos_indicadores]  WITH CHECK ADD  CONSTRAINT [fk_acessos_indicadores_cd_transportadora] FOREIGN KEY([aci_cd_transportadora])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_acessos_indicadores] CHECK CONSTRAINT [fk_acessos_indicadores_cd_transportadora]
GO
ALTER TABLE [dbo].[tb_acessos_indicadores]  WITH CHECK ADD  CONSTRAINT [fk_acessos_indicadores_cd_usuario] FOREIGN KEY([aci_cd_usuario])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_acessos_indicadores] CHECK CONSTRAINT [fk_acessos_indicadores_cd_usuario]
GO
ALTER TABLE [dbo].[tb_action_controller]  WITH CHECK ADD  CONSTRAINT [fk_acc_act_cd_action] FOREIGN KEY([acc_cd_action])
REFERENCES [dbo].[tb_action] ([act_cd_action])
GO
ALTER TABLE [dbo].[tb_action_controller] CHECK CONSTRAINT [fk_acc_act_cd_action]
GO
ALTER TABLE [dbo].[tb_action_controller]  WITH CHECK ADD  CONSTRAINT [fk_acc_ctr_cd_controller] FOREIGN KEY([acc_cd_controller])
REFERENCES [dbo].[tb_controller] ([ctr_cd_controller])
GO
ALTER TABLE [dbo].[tb_action_controller] CHECK CONSTRAINT [fk_acc_ctr_cd_controller]
GO
ALTER TABLE [dbo].[tb_action_grupo_acesso]  WITH CHECK ADD  CONSTRAINT [fk_aga_acc_cd_action_controller] FOREIGN KEY([aga_cd_action_controller])
REFERENCES [dbo].[tb_action_controller] ([acc_cd_action_controller])
GO
ALTER TABLE [dbo].[tb_action_grupo_acesso] CHECK CONSTRAINT [fk_aga_acc_cd_action_controller]
GO
ALTER TABLE [dbo].[tb_action_grupo_acesso]  WITH CHECK ADD  CONSTRAINT [fk_aga_gpa_cd_grupo_acesso] FOREIGN KEY([aga_cd_grupo_acesso])
REFERENCES [dbo].[tb_grupo_acesso] ([gpa_cd_grupo_acesso])
GO
ALTER TABLE [dbo].[tb_action_grupo_acesso] CHECK CONSTRAINT [fk_aga_gpa_cd_grupo_acesso]
GO
ALTER TABLE [dbo].[tb_alarmes]  WITH CHECK ADD FOREIGN KEY([IdGrupo])
REFERENCES [dbo].[tb_grupos_alarmes] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_ama_anexo_motorista]  WITH CHECK ADD  CONSTRAINT [fk_tb_ama_anexo_motorista_tb_arquivos] FOREIGN KEY([ama_cd_codigo_upload])
REFERENCES [dbo].[tb_arquivos] ([arq_cd_arquivo])
GO
ALTER TABLE [dbo].[tb_ama_anexo_motorista] CHECK CONSTRAINT [fk_tb_ama_anexo_motorista_tb_arquivos]
GO
ALTER TABLE [dbo].[tb_ama_anexo_motorista]  WITH CHECK ADD  CONSTRAINT [fk_tb_ama_anexo_motorista_tb_motorista] FOREIGN KEY([ama_cd_motorista])
REFERENCES [dbo].[tb_motorista] ([mot_cd_motorista])
GO
ALTER TABLE [dbo].[tb_ama_anexo_motorista] CHECK CONSTRAINT [fk_tb_ama_anexo_motorista_tb_motorista]
GO
ALTER TABLE [dbo].[tb_ama_anexo_motorista]  WITH CHECK ADD  CONSTRAINT [fk_tb_ama_anexo_motorista_tb_usuario_criacao] FOREIGN KEY([ama_cd_usr_criacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_ama_anexo_motorista] CHECK CONSTRAINT [fk_tb_ama_anexo_motorista_tb_usuario_criacao]
GO
ALTER TABLE [dbo].[tb_ama_anexo_motorista]  WITH CHECK ADD  CONSTRAINT [fk_tb_ama_anexo_motorista_tb_usuario_modificacao] FOREIGN KEY([ama_cd_usr_modificacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_ama_anexo_motorista] CHECK CONSTRAINT [fk_tb_ama_anexo_motorista_tb_usuario_modificacao]
GO
ALTER TABLE [dbo].[tb_ans_anexo_sinistro]  WITH CHECK ADD  CONSTRAINT [fk_tb_ans_anexo_sinistro_tb_arquivos] FOREIGN KEY([ans_cd_codigo_upload])
REFERENCES [dbo].[tb_arquivos] ([arq_cd_arquivo])
GO
ALTER TABLE [dbo].[tb_ans_anexo_sinistro] CHECK CONSTRAINT [fk_tb_ans_anexo_sinistro_tb_arquivos]
GO
ALTER TABLE [dbo].[tb_app_mobile]  WITH CHECK ADD  CONSTRAINT [fk_app_mobile_usr] FOREIGN KEY([usr_cd_usuario])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_app_mobile] CHECK CONSTRAINT [fk_app_mobile_usr]
GO
ALTER TABLE [dbo].[tb_app_notificacoes_usuarios]  WITH CHECK ADD  CONSTRAINT [fk_app_notificacoes_usuarios_usr] FOREIGN KEY([usr_cd_usuario])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_app_notificacoes_usuarios] CHECK CONSTRAINT [fk_app_notificacoes_usuarios_usr]
GO
ALTER TABLE [dbo].[tb_app_notificacoes_usuarios]  WITH CHECK ADD  CONSTRAINT [fk_app_notificacoes_usuarios_usr_criacao] FOREIGN KEY([usr_cd_usuario_criacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_app_notificacoes_usuarios] CHECK CONSTRAINT [fk_app_notificacoes_usuarios_usr_criacao]
GO
ALTER TABLE [dbo].[tb_app_notificacoes_usuarios]  WITH CHECK ADD  CONSTRAINT [fk_app_notificacoes_usuarios_usr_modificacao] FOREIGN KEY([usr_cd_usuario_modificacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_app_notificacoes_usuarios] CHECK CONSTRAINT [fk_app_notificacoes_usuarios_usr_modificacao]
GO
ALTER TABLE [dbo].[tb_aprovacao_lancamento_manual]  WITH CHECK ADD  CONSTRAINT [fk_aprovacao_lancamento_manual_cod_cliente] FOREIGN KEY([alm_cd_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_aprovacao_lancamento_manual] CHECK CONSTRAINT [fk_aprovacao_lancamento_manual_cod_cliente]
GO
ALTER TABLE [dbo].[tb_aprovacao_lancamento_manual]  WITH CHECK ADD  CONSTRAINT [fk_aprovacao_lancamento_manual_usuario_aprovacao] FOREIGN KEY([alm_cd_usuario_aprovacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_aprovacao_lancamento_manual] CHECK CONSTRAINT [fk_aprovacao_lancamento_manual_usuario_aprovacao]
GO
ALTER TABLE [dbo].[tb_aprovacao_lancamento_manual]  WITH CHECK ADD  CONSTRAINT [fk_aprovacao_lancamento_manual_usuario_criacao] FOREIGN KEY([alm_cd_usuario_criacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_aprovacao_lancamento_manual] CHECK CONSTRAINT [fk_aprovacao_lancamento_manual_usuario_criacao]
GO
ALTER TABLE [dbo].[tb_aprovacao_lancamento_manual]  WITH CHECK ADD  CONSTRAINT [fk_aprovacao_lancamento_manual_usuario_modificacao] FOREIGN KEY([alm_cd_usuario_modificacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_aprovacao_lancamento_manual] CHECK CONSTRAINT [fk_aprovacao_lancamento_manual_usuario_modificacao]
GO
ALTER TABLE [dbo].[tb_atm_pedagios]  WITH CHECK ADD  CONSTRAINT [fk_tb_atm_pedagios_tb_arquivos_arq_cd_arquivo] FOREIGN KEY([atp_cd_codigo_upload])
REFERENCES [dbo].[tb_arquivos] ([arq_cd_arquivo])
GO
ALTER TABLE [dbo].[tb_atm_pedagios] CHECK CONSTRAINT [fk_tb_atm_pedagios_tb_arquivos_arq_cd_arquivo]
GO
ALTER TABLE [dbo].[tb_atm_pedagios]  WITH CHECK ADD  CONSTRAINT [fk_tb_atm_pedagios_tb_clientes] FOREIGN KEY([atp_cd_codigo_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_atm_pedagios] CHECK CONSTRAINT [fk_tb_atm_pedagios_tb_clientes]
GO
ALTER TABLE [dbo].[tb_atm_pedagios]  WITH CHECK ADD  CONSTRAINT [fk_tb_atm_pedagios_tb_usuario_operador] FOREIGN KEY([atp_cd_cod_usuario_operador])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_atm_pedagios] CHECK CONSTRAINT [fk_tb_atm_pedagios_tb_usuario_operador]
GO
ALTER TABLE [dbo].[tb_atm_pedagios]  WITH CHECK ADD  CONSTRAINT [fk_tb_atm_pedagios_tb_usuario_operador_atp_cd_usr_criacao] FOREIGN KEY([atp_cd_usr_criacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_atm_pedagios] CHECK CONSTRAINT [fk_tb_atm_pedagios_tb_usuario_operador_atp_cd_usr_criacao]
GO
ALTER TABLE [dbo].[tb_atm_pedagios]  WITH CHECK ADD  CONSTRAINT [fk_tb_atm_pedagios_tb_usuario_operador_atp_cd_usr_modificacao] FOREIGN KEY([atp_cd_usr_modificacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_atm_pedagios] CHECK CONSTRAINT [fk_tb_atm_pedagios_tb_usuario_operador_atp_cd_usr_modificacao]
GO
ALTER TABLE [dbo].[tb_atm_pedagios]  WITH CHECK ADD  CONSTRAINT [fk_tb_atm_pedagios_tb_usuarios] FOREIGN KEY([atp_cd_codigo_usuario_motorista])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_atm_pedagios] CHECK CONSTRAINT [fk_tb_atm_pedagios_tb_usuarios]
GO
ALTER TABLE [dbo].[tb_aud_km_rota_uso_devido]  WITH CHECK ADD  CONSTRAINT [FK_tb_aud_km_rota_uso_devido_cliente] FOREIGN KEY([akr_cd_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_aud_km_rota_uso_devido] CHECK CONSTRAINT [FK_tb_aud_km_rota_uso_devido_cliente]
GO
ALTER TABLE [dbo].[tb_bases]  WITH CHECK ADD  CONSTRAINT [FK_tb_bases_base_fm_vinculada] FOREIGN KEY([bss_cd_base_fm_vinculada])
REFERENCES [dbo].[tb_bases] ([bss_cd_base])
GO
ALTER TABLE [dbo].[tb_bases] CHECK CONSTRAINT [FK_tb_bases_base_fm_vinculada]
GO
ALTER TABLE [dbo].[tb_bases]  WITH CHECK ADD  CONSTRAINT [fk_tb_bases_tb_lista_regra_ciclo] FOREIGN KEY([bss_regra_ciclo])
REFERENCES [dbo].[tb_lista] ([lst_cd_lista])
GO
ALTER TABLE [dbo].[tb_bases] CHECK CONSTRAINT [fk_tb_bases_tb_lista_regra_ciclo]
GO
ALTER TABLE [dbo].[tb_bases_permissoes]  WITH CHECK ADD  CONSTRAINT [fk_bsp_cli_cod_cliente] FOREIGN KEY([bsp_cod_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_bases_permissoes] CHECK CONSTRAINT [fk_bsp_cli_cod_cliente]
GO
ALTER TABLE [dbo].[tb_bases_permissoes]  WITH CHECK ADD  CONSTRAINT [fk_usr_bsp_cd_usuario] FOREIGN KEY([bsp_cd_usuario])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_bases_permissoes] CHECK CONSTRAINT [fk_usr_bsp_cd_usuario]
GO
ALTER TABLE [dbo].[tb_bases_profissionais]  WITH CHECK ADD  CONSTRAINT [FK_tb_bases_profissionais_tb_motorista] FOREIGN KEY([tbp_cd_profissional])
REFERENCES [dbo].[tb_motorista] ([mot_cd_motorista])
GO
ALTER TABLE [dbo].[tb_bases_profissionais] CHECK CONSTRAINT [FK_tb_bases_profissionais_tb_motorista]
GO
ALTER TABLE [dbo].[tb_chat]  WITH CHECK ADD  CONSTRAINT [FK_tb_chat_tb_usuario] FOREIGN KEY([cht_cd_usuario])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_chat] CHECK CONSTRAINT [FK_tb_chat_tb_usuario]
GO
ALTER TABLE [dbo].[tb_chat]  WITH CHECK ADD  CONSTRAINT [FK_tb_chat_tb_usuario1] FOREIGN KEY([cht_cd_usuario_cricao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_chat] CHECK CONSTRAINT [FK_tb_chat_tb_usuario1]
GO
ALTER TABLE [dbo].[tb_cliente_alarmes]  WITH CHECK ADD FOREIGN KEY([id_alarme])
REFERENCES [dbo].[tb_alarmes] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_clientes]  WITH CHECK ADD  CONSTRAINT [fk_clientes_usr_criacao] FOREIGN KEY([cli_cd_usr_criacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_clientes] CHECK CONSTRAINT [fk_clientes_usr_criacao]
GO
ALTER TABLE [dbo].[tb_clientes]  WITH CHECK ADD  CONSTRAINT [fk_clientes_usr_modificacao] FOREIGN KEY([cli_cd_usr_modificacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_clientes] CHECK CONSTRAINT [fk_clientes_usr_modificacao]
GO
ALTER TABLE [dbo].[tb_comprovante_enviado_historico]  WITH CHECK ADD  CONSTRAINT [FK_comprovante_enviado_historico_comprovante_enviado] FOREIGN KEY([ceh_cd_comprovante_enviado])
REFERENCES [dbo].[tb_comprovantes_enviados] ([cme_cd_comprovante_enviado])
GO
ALTER TABLE [dbo].[tb_comprovante_enviado_historico] CHECK CONSTRAINT [FK_comprovante_enviado_historico_comprovante_enviado]
GO
ALTER TABLE [dbo].[tb_comprovantes]  WITH CHECK ADD  CONSTRAINT [fk_comprovante_cod_cliente] FOREIGN KEY([cmp_cd_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_comprovantes] CHECK CONSTRAINT [fk_comprovante_cod_cliente]
GO
ALTER TABLE [dbo].[tb_comprovantes]  WITH CHECK ADD  CONSTRAINT [fk_comprovante_usuario_criacao] FOREIGN KEY([cmp_cd_usuario_criacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_comprovantes] CHECK CONSTRAINT [fk_comprovante_usuario_criacao]
GO
ALTER TABLE [dbo].[tb_comprovantes]  WITH CHECK ADD  CONSTRAINT [fk_comprovante_usuario_modificacao] FOREIGN KEY([cmp_cd_usuario_modificacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_comprovantes] CHECK CONSTRAINT [fk_comprovante_usuario_modificacao]
GO
ALTER TABLE [dbo].[tb_comprovantes_enviados]  WITH CHECK ADD  CONSTRAINT [fk_comprovante_enviado_cd_comprovante] FOREIGN KEY([cme_cd_comprovante])
REFERENCES [dbo].[tb_comprovantes] ([cmp_cd_comprovante])
GO
ALTER TABLE [dbo].[tb_comprovantes_enviados] CHECK CONSTRAINT [fk_comprovante_enviado_cd_comprovante]
GO
ALTER TABLE [dbo].[tb_comprovantes_enviados]  WITH CHECK ADD  CONSTRAINT [fk_comprovante_enviado_cod_cliente] FOREIGN KEY([cme_cd_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_comprovantes_enviados] CHECK CONSTRAINT [fk_comprovante_enviado_cod_cliente]
GO
ALTER TABLE [dbo].[tb_comprovantes_enviados]  WITH CHECK ADD  CONSTRAINT [fk_comprovante_enviado_usuario] FOREIGN KEY([cme_cd_usuario])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_comprovantes_enviados] CHECK CONSTRAINT [fk_comprovante_enviado_usuario]
GO
ALTER TABLE [dbo].[tb_comprovantes_enviados]  WITH CHECK ADD  CONSTRAINT [fk_comprovante_enviado_usuario_criacao] FOREIGN KEY([cme_cd_usuario_criacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_comprovantes_enviados] CHECK CONSTRAINT [fk_comprovante_enviado_usuario_criacao]
GO
ALTER TABLE [dbo].[tb_comprovantes_enviados]  WITH CHECK ADD  CONSTRAINT [fk_comprovante_enviado_usuario_modificacao] FOREIGN KEY([cme_cd_usuario_modificacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_comprovantes_enviados] CHECK CONSTRAINT [fk_comprovante_enviado_usuario_modificacao]
GO
ALTER TABLE [dbo].[tb_comprovantes_pagamento_seguradora]  WITH CHECK ADD  CONSTRAINT [fkcomprovantes_pagamento_seguradora_cod_cliente] FOREIGN KEY([cps_cd_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_comprovantes_pagamento_seguradora] CHECK CONSTRAINT [fkcomprovantes_pagamento_seguradora_cod_cliente]
GO
ALTER TABLE [dbo].[tb_comprovantes_pagamento_seguradora]  WITH CHECK ADD  CONSTRAINT [fkcomprovantes_pagamento_seguradora_usuario] FOREIGN KEY([cps_cd_usuario])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_comprovantes_pagamento_seguradora] CHECK CONSTRAINT [fkcomprovantes_pagamento_seguradora_usuario]
GO
ALTER TABLE [dbo].[tb_comprovantes_pagamento_seguradora]  WITH CHECK ADD  CONSTRAINT [fkcomprovantes_pagamento_seguradora_usuario_criacao] FOREIGN KEY([cps_cd_usuario_criacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_comprovantes_pagamento_seguradora] CHECK CONSTRAINT [fkcomprovantes_pagamento_seguradora_usuario_criacao]
GO
ALTER TABLE [dbo].[tb_comprovantes_pagamento_seguradora]  WITH CHECK ADD  CONSTRAINT [fkcomprovantes_pagamento_seguradora_usuario_modificacao] FOREIGN KEY([cps_cd_usuario_modificacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_comprovantes_pagamento_seguradora] CHECK CONSTRAINT [fkcomprovantes_pagamento_seguradora_usuario_modificacao]
GO
ALTER TABLE [dbo].[tb_comprovantes_tipo_contrato]  WITH CHECK ADD  CONSTRAINT [fk_comprovantes_tipo_contrato_comprovantes] FOREIGN KEY([ctc_cd_comprovante])
REFERENCES [dbo].[tb_comprovantes] ([cmp_cd_comprovante])
GO
ALTER TABLE [dbo].[tb_comprovantes_tipo_contrato] CHECK CONSTRAINT [fk_comprovantes_tipo_contrato_comprovantes]
GO
ALTER TABLE [dbo].[tb_comprovantes_tipo_contrato]  WITH CHECK ADD  CONSTRAINT [fk_comprovantes_tipo_contrato_tipo_contrato] FOREIGN KEY([ctc_cd_tipo_contrato])
REFERENCES [dbo].[tb_tipo_contrato] ([ttc_cd_tipo_contrato])
GO
ALTER TABLE [dbo].[tb_comprovantes_tipo_contrato] CHECK CONSTRAINT [fk_comprovantes_tipo_contrato_tipo_contrato]
GO
ALTER TABLE [dbo].[tb_conferencia_cargas]  WITH CHECK ADD  CONSTRAINT [fk_conferencia_cargas] FOREIGN KEY([cfr_cd_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_conferencia_cargas] CHECK CONSTRAINT [fk_conferencia_cargas]
GO
ALTER TABLE [dbo].[tb_conferencia_cargas]  WITH CHECK ADD  CONSTRAINT [fk_conferencia_cargas_status] FOREIGN KEY([cfr_cd_status_conferencia])
REFERENCES [dbo].[tb_lista] ([lst_cd_lista])
GO
ALTER TABLE [dbo].[tb_conferencia_cargas] CHECK CONSTRAINT [fk_conferencia_cargas_status]
GO
ALTER TABLE [dbo].[tb_conferencia_cargas]  WITH CHECK ADD  CONSTRAINT [fk_conferencia_cargas_usr_fim] FOREIGN KEY([cfr_usr_fim_conferencia])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_conferencia_cargas] CHECK CONSTRAINT [fk_conferencia_cargas_usr_fim]
GO
ALTER TABLE [dbo].[tb_conferencia_cargas]  WITH CHECK ADD  CONSTRAINT [fk_conferencia_cargas_usr_inicio] FOREIGN KEY([cfr_usr_inicio_conferencia])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_conferencia_cargas] CHECK CONSTRAINT [fk_conferencia_cargas_usr_inicio]
GO
ALTER TABLE [dbo].[tb_conferencia_cargas_pacotes]  WITH CHECK ADD  CONSTRAINT [fk_cargas_pacotes_cliente] FOREIGN KEY([cfp_cd_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_conferencia_cargas_pacotes] CHECK CONSTRAINT [fk_cargas_pacotes_cliente]
GO
ALTER TABLE [dbo].[tb_conferencia_cargas_pacotes]  WITH CHECK ADD  CONSTRAINT [fk_cargas_pacotes_conferencia] FOREIGN KEY([cfp_cd_conferencia_cargas])
REFERENCES [dbo].[tb_conferencia_cargas] ([cfr_cd_conferencia_cargas])
GO
ALTER TABLE [dbo].[tb_conferencia_cargas_pacotes] CHECK CONSTRAINT [fk_cargas_pacotes_conferencia]
GO
ALTER TABLE [dbo].[tb_conferencia_cargas_pacotes]  WITH CHECK ADD  CONSTRAINT [fk_cargas_pacotes_status] FOREIGN KEY([cfp_cd_status_pacote])
REFERENCES [dbo].[tb_lista] ([lst_cd_lista])
GO
ALTER TABLE [dbo].[tb_conferencia_cargas_pacotes] CHECK CONSTRAINT [fk_cargas_pacotes_status]
GO
ALTER TABLE [dbo].[tb_conferencia_cargas_pacotes]  WITH CHECK ADD  CONSTRAINT [fk_cargas_pacotes_tipo] FOREIGN KEY([cfp_cd_tipo_pacote])
REFERENCES [dbo].[tb_lista] ([lst_cd_lista])
GO
ALTER TABLE [dbo].[tb_conferencia_cargas_pacotes] CHECK CONSTRAINT [fk_cargas_pacotes_tipo]
GO
ALTER TABLE [dbo].[tb_conferencia_cargas_pacotes]  WITH CHECK ADD  CONSTRAINT [fk_cargas_pacotes_usuario] FOREIGN KEY([cfp_cd_usuario_conferencia])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_conferencia_cargas_pacotes] CHECK CONSTRAINT [fk_cargas_pacotes_usuario]
GO
ALTER TABLE [dbo].[tb_conferencia_cargas_pacotes_inconsistente]  WITH CHECK ADD  CONSTRAINT [fk_cargas_inconsistente_status] FOREIGN KEY([cne_cd_status_pacote])
REFERENCES [dbo].[tb_lista] ([lst_cd_lista])
GO
ALTER TABLE [dbo].[tb_conferencia_cargas_pacotes_inconsistente] CHECK CONSTRAINT [fk_cargas_inconsistente_status]
GO
ALTER TABLE [dbo].[tb_conferencia_cargas_pacotes_inconsistente]  WITH CHECK ADD  CONSTRAINT [fk_cne_cliente] FOREIGN KEY([cne_cd_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_conferencia_cargas_pacotes_inconsistente] CHECK CONSTRAINT [fk_cne_cliente]
GO
ALTER TABLE [dbo].[tb_conferencia_cargas_pacotes_inconsistente]  WITH CHECK ADD  CONSTRAINT [fk_cne_usuario] FOREIGN KEY([cne_cd_usuario_inclusao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_conferencia_cargas_pacotes_inconsistente] CHECK CONSTRAINT [fk_cne_usuario]
GO
ALTER TABLE [dbo].[tb_contratos]  WITH CHECK ADD  CONSTRAINT [fk_contrato_usuario_criacao] FOREIGN KEY([ctt_cd_usuario_criacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_contratos] CHECK CONSTRAINT [fk_contrato_usuario_criacao]
GO
ALTER TABLE [dbo].[tb_contratos]  WITH CHECK ADD  CONSTRAINT [fk_contrato_usuario_modificacao] FOREIGN KEY([ctt_cd_usuario_modificacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_contratos] CHECK CONSTRAINT [fk_contrato_usuario_modificacao]
GO
ALTER TABLE [dbo].[tb_contratos_assinados]  WITH CHECK ADD  CONSTRAINT [fk_contratos_assinados_arquivo] FOREIGN KEY([cta_cd_pdf])
REFERENCES [dbo].[tb_arquivos] ([arq_cd_arquivo])
GO
ALTER TABLE [dbo].[tb_contratos_assinados] CHECK CONSTRAINT [fk_contratos_assinados_arquivo]
GO
ALTER TABLE [dbo].[tb_contratos_assinados]  WITH CHECK ADD  CONSTRAINT [fk_contratos_assinados_contrato] FOREIGN KEY([cta_cd_contrato])
REFERENCES [dbo].[tb_contratos] ([ctt_cd_contrato])
GO
ALTER TABLE [dbo].[tb_contratos_assinados] CHECK CONSTRAINT [fk_contratos_assinados_contrato]
GO
ALTER TABLE [dbo].[tb_contratos_assinados]  WITH CHECK ADD  CONSTRAINT [fk_contratos_assinados_usuario] FOREIGN KEY([cta_cd_usuario])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_contratos_assinados] CHECK CONSTRAINT [fk_contratos_assinados_usuario]
GO
ALTER TABLE [dbo].[tb_contratos_assinados_eventos]  WITH CHECK ADD  CONSTRAINT [fk_contratos_assinados_evento_contrato] FOREIGN KEY([cte_cd_contrato])
REFERENCES [dbo].[tb_contratos] ([ctt_cd_contrato])
GO
ALTER TABLE [dbo].[tb_contratos_assinados_eventos] CHECK CONSTRAINT [fk_contratos_assinados_evento_contrato]
GO
ALTER TABLE [dbo].[tb_contratos_assinados_eventos]  WITH CHECK ADD  CONSTRAINT [fk_contratos_assinados_eventos_usuario] FOREIGN KEY([cte_cd_usuario])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_contratos_assinados_eventos] CHECK CONSTRAINT [fk_contratos_assinados_eventos_usuario]
GO
ALTER TABLE [dbo].[tb_contratos_assinantes]  WITH CHECK ADD  CONSTRAINT [fk_contratos_assinantes_cliente] FOREIGN KEY([cta_cd_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_contratos_assinantes] CHECK CONSTRAINT [fk_contratos_assinantes_cliente]
GO
ALTER TABLE [dbo].[tb_contratos_assinantes]  WITH CHECK ADD  CONSTRAINT [fk_contratos_assinantes_usuario_criacao] FOREIGN KEY([cta_cd_usuario_criacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_contratos_assinantes] CHECK CONSTRAINT [fk_contratos_assinantes_usuario_criacao]
GO
ALTER TABLE [dbo].[tb_contratos_assinantes]  WITH CHECK ADD  CONSTRAINT [fk_contratos_assinantes_usuario_modificacao] FOREIGN KEY([cta_cd_usuario_modificacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_contratos_assinantes] CHECK CONSTRAINT [fk_contratos_assinantes_usuario_modificacao]
GO
ALTER TABLE [dbo].[tb_contratos_assinatura_onboarding]  WITH CHECK ADD  CONSTRAINT [fk_assinatura_onboarding_cliente] FOREIGN KEY([cao_cd_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_contratos_assinatura_onboarding] CHECK CONSTRAINT [fk_assinatura_onboarding_cliente]
GO
ALTER TABLE [dbo].[tb_contratos_assinatura_onboarding]  WITH CHECK ADD  CONSTRAINT [fk_assinatura_onboarding_contrato] FOREIGN KEY([cao_cd_contrato])
REFERENCES [dbo].[tb_contratos] ([ctt_cd_contrato])
GO
ALTER TABLE [dbo].[tb_contratos_assinatura_onboarding] CHECK CONSTRAINT [fk_assinatura_onboarding_contrato]
GO
ALTER TABLE [dbo].[tb_contratos_documentos_enviados]  WITH CHECK ADD  CONSTRAINT [fk_contrato_documento_enviado_cd_contrato] FOREIGN KEY([cde_cd_contrato])
REFERENCES [dbo].[tb_contratos] ([ctt_cd_contrato])
GO
ALTER TABLE [dbo].[tb_contratos_documentos_enviados] CHECK CONSTRAINT [fk_contrato_documento_enviado_cd_contrato]
GO
ALTER TABLE [dbo].[tb_contratos_documentos_enviados]  WITH CHECK ADD  CONSTRAINT [fk_contrato_documento_enviado_cd_contrato_documento_necessario] FOREIGN KEY([cde_cd_contrato_documento_necessario])
REFERENCES [dbo].[tb_contratos_documentos_necessarios] ([cdn_cd_contrato_documento_necessario])
GO
ALTER TABLE [dbo].[tb_contratos_documentos_enviados] CHECK CONSTRAINT [fk_contrato_documento_enviado_cd_contrato_documento_necessario]
GO
ALTER TABLE [dbo].[tb_contratos_documentos_enviados]  WITH CHECK ADD  CONSTRAINT [fk_contrato_documento_enviado_cod_cliente] FOREIGN KEY([cde_cd_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_contratos_documentos_enviados] CHECK CONSTRAINT [fk_contrato_documento_enviado_cod_cliente]
GO
ALTER TABLE [dbo].[tb_contratos_documentos_enviados]  WITH CHECK ADD  CONSTRAINT [fk_contrato_documento_enviado_usuario] FOREIGN KEY([cde_cd_usuario])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_contratos_documentos_enviados] CHECK CONSTRAINT [fk_contrato_documento_enviado_usuario]
GO
ALTER TABLE [dbo].[tb_contratos_documentos_enviados]  WITH CHECK ADD  CONSTRAINT [fk_contrato_documento_enviado_usuario_criacao] FOREIGN KEY([cde_cd_usuario_criacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_contratos_documentos_enviados] CHECK CONSTRAINT [fk_contrato_documento_enviado_usuario_criacao]
GO
ALTER TABLE [dbo].[tb_contratos_documentos_enviados]  WITH CHECK ADD  CONSTRAINT [fk_contrato_documento_enviado_usuario_modificacao] FOREIGN KEY([cde_cd_usuario_modificacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_contratos_documentos_enviados] CHECK CONSTRAINT [fk_contrato_documento_enviado_usuario_modificacao]
GO
ALTER TABLE [dbo].[tb_contratos_documentos_necessarios]  WITH CHECK ADD  CONSTRAINT [fk_contrato_documento_necessario_cd_contrato] FOREIGN KEY([cdn_cd_contrato])
REFERENCES [dbo].[tb_contratos] ([ctt_cd_contrato])
GO
ALTER TABLE [dbo].[tb_contratos_documentos_necessarios] CHECK CONSTRAINT [fk_contrato_documento_necessario_cd_contrato]
GO
ALTER TABLE [dbo].[tb_contratos_documentos_necessarios]  WITH CHECK ADD  CONSTRAINT [fk_contrato_documento_necessario_cod_cliente] FOREIGN KEY([cdn_cd_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_contratos_documentos_necessarios] CHECK CONSTRAINT [fk_contrato_documento_necessario_cod_cliente]
GO
ALTER TABLE [dbo].[tb_contratos_documentos_necessarios]  WITH CHECK ADD  CONSTRAINT [fk_contrato_documento_necessario_usuario_criacao] FOREIGN KEY([cdn_cd_usuario_criacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_contratos_documentos_necessarios] CHECK CONSTRAINT [fk_contrato_documento_necessario_usuario_criacao]
GO
ALTER TABLE [dbo].[tb_contratos_documentos_necessarios]  WITH CHECK ADD  CONSTRAINT [fk_contrato_documento_necessario_usuario_modificacao] FOREIGN KEY([cdn_cd_usuario_modificacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_contratos_documentos_necessarios] CHECK CONSTRAINT [fk_contrato_documento_necessario_usuario_modificacao]
GO
ALTER TABLE [dbo].[tb_contratos_integracao_log]  WITH CHECK ADD  CONSTRAINT [fk_contratos_integracao_log_contrato] FOREIGN KEY([cil_cd_contrato])
REFERENCES [dbo].[tb_contratos] ([ctt_cd_contrato])
GO
ALTER TABLE [dbo].[tb_contratos_integracao_log] CHECK CONSTRAINT [fk_contratos_integracao_log_contrato]
GO
ALTER TABLE [dbo].[tb_contratos_integracao_log]  WITH CHECK ADD  CONSTRAINT [fk_contratos_integracao_log_usuario] FOREIGN KEY([cil_cd_usuario])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_contratos_integracao_log] CHECK CONSTRAINT [fk_contratos_integracao_log_usuario]
GO
ALTER TABLE [dbo].[tb_contratos_tipo_contrato]  WITH CHECK ADD  CONSTRAINT [fk_contratos_tipo_contrato_contratos] FOREIGN KEY([ctn_cd_contrato])
REFERENCES [dbo].[tb_contratos] ([ctt_cd_contrato])
GO
ALTER TABLE [dbo].[tb_contratos_tipo_contrato] CHECK CONSTRAINT [fk_contratos_tipo_contrato_contratos]
GO
ALTER TABLE [dbo].[tb_contratos_tipo_contrato]  WITH CHECK ADD  CONSTRAINT [fk_contratos_tipo_contrato_tipo_contrato] FOREIGN KEY([ctn_cd_tipo_contrato])
REFERENCES [dbo].[tb_tipo_contrato] ([ttc_cd_tipo_contrato])
GO
ALTER TABLE [dbo].[tb_contratos_tipo_contrato] CHECK CONSTRAINT [fk_contratos_tipo_contrato_tipo_contrato]
GO
ALTER TABLE [dbo].[tb_controller]  WITH CHECK ADD  CONSTRAINT [fk_ctr_cd_controller_pai] FOREIGN KEY([ctr_cd_controller_pai])
REFERENCES [dbo].[tb_controller] ([ctr_cd_controller])
GO
ALTER TABLE [dbo].[tb_controller] CHECK CONSTRAINT [fk_ctr_cd_controller_pai]
GO
ALTER TABLE [dbo].[tb_controller]  WITH CHECK ADD  CONSTRAINT [fk_ctr_cd_visibilidade_controller] FOREIGN KEY([ctr_cd_visibilidade_controller])
REFERENCES [dbo].[tb_visibilidade_controller] ([vct_cd_visibilidade_controller])
GO
ALTER TABLE [dbo].[tb_controller] CHECK CONSTRAINT [fk_ctr_cd_visibilidade_controller]
GO
ALTER TABLE [dbo].[tb_crud]  WITH CHECK ADD  CONSTRAINT [FK_tb_crud_tb_controller] FOREIGN KEY([crd_cd_controller])
REFERENCES [dbo].[tb_controller] ([ctr_cd_controller])
GO
ALTER TABLE [dbo].[tb_crud] CHECK CONSTRAINT [FK_tb_crud_tb_controller]
GO
ALTER TABLE [dbo].[tb_crud_teste]  WITH CHECK ADD  CONSTRAINT [FK_tb_crud_teste_tb_usuario] FOREIGN KEY([tst_cd_usuario])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_crud_teste] CHECK CONSTRAINT [FK_tb_crud_teste_tb_usuario]
GO
ALTER TABLE [dbo].[tb_cte_lotes]  WITH CHECK ADD  CONSTRAINT [fk_cte_lotes_usr_criacao] FOREIGN KEY([cte_cd_usr_criacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_cte_lotes] CHECK CONSTRAINT [fk_cte_lotes_usr_criacao]
GO
ALTER TABLE [dbo].[tb_cte_lotes]  WITH CHECK ADD  CONSTRAINT [fk_cte_lotes_usr_modificacao] FOREIGN KEY([cte_cd_usr_modificacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_cte_lotes] CHECK CONSTRAINT [fk_cte_lotes_usr_modificacao]
GO
ALTER TABLE [dbo].[tb_cte_lotes_anexos]  WITH CHECK ADD  CONSTRAINT [fk_cte_lote_anexos_cte_lotes] FOREIGN KEY([cla_cd_cte_lote])
REFERENCES [dbo].[tb_cte_lotes] ([cte_cd_cte_lote])
GO
ALTER TABLE [dbo].[tb_cte_lotes_anexos] CHECK CONSTRAINT [fk_cte_lote_anexos_cte_lotes]
GO
ALTER TABLE [dbo].[tb_disponibilidade_motorista]  WITH CHECK ADD  CONSTRAINT [fk_disponibilidade_motorista_cod_cliente] FOREIGN KEY([dpm_cd_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_disponibilidade_motorista] CHECK CONSTRAINT [fk_disponibilidade_motorista_cod_cliente]
GO
ALTER TABLE [dbo].[tb_disponibilidade_motorista]  WITH CHECK ADD  CONSTRAINT [fk_disponibilidade_motorista_usuario] FOREIGN KEY([dpm_cd_usuario])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_disponibilidade_motorista] CHECK CONSTRAINT [fk_disponibilidade_motorista_usuario]
GO
ALTER TABLE [dbo].[tb_disponibilidade_motorista]  WITH CHECK ADD  CONSTRAINT [fk_disponibilidade_motorista_usuario_criacao] FOREIGN KEY([dpm_cd_usuario_criacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_disponibilidade_motorista] CHECK CONSTRAINT [fk_disponibilidade_motorista_usuario_criacao]
GO
ALTER TABLE [dbo].[tb_disponibilidade_motorista]  WITH CHECK ADD  CONSTRAINT [fk_disponibilidade_motorista_usuario_modificacao] FOREIGN KEY([dpm_cd_usuario_modificacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_disponibilidade_motorista] CHECK CONSTRAINT [fk_disponibilidade_motorista_usuario_modificacao]
GO
ALTER TABLE [dbo].[tb_documentos]  WITH CHECK ADD  CONSTRAINT [fk_documento_cod_cliente] FOREIGN KEY([dcm_cd_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_documentos] CHECK CONSTRAINT [fk_documento_cod_cliente]
GO
ALTER TABLE [dbo].[tb_documentos]  WITH CHECK ADD  CONSTRAINT [fk_documento_usuario_criacao] FOREIGN KEY([dcm_cd_usuario_criacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_documentos] CHECK CONSTRAINT [fk_documento_usuario_criacao]
GO
ALTER TABLE [dbo].[tb_documentos]  WITH CHECK ADD  CONSTRAINT [fk_documento_usuario_modificacao] FOREIGN KEY([dcm_cd_usuario_modificacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_documentos] CHECK CONSTRAINT [fk_documento_usuario_modificacao]
GO
ALTER TABLE [dbo].[tb_documentos_enviados]  WITH CHECK ADD  CONSTRAINT [fk_documento_enviado_cd_documento] FOREIGN KEY([dce_cd_documento])
REFERENCES [dbo].[tb_documentos] ([dcm_cd_documento])
GO
ALTER TABLE [dbo].[tb_documentos_enviados] CHECK CONSTRAINT [fk_documento_enviado_cd_documento]
GO
ALTER TABLE [dbo].[tb_documentos_enviados]  WITH CHECK ADD  CONSTRAINT [fk_documento_enviado_cod_cliente] FOREIGN KEY([dce_cd_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_documentos_enviados] CHECK CONSTRAINT [fk_documento_enviado_cod_cliente]
GO
ALTER TABLE [dbo].[tb_documentos_enviados]  WITH CHECK ADD  CONSTRAINT [fk_documento_enviado_usuario] FOREIGN KEY([dce_cd_usuario])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_documentos_enviados] CHECK CONSTRAINT [fk_documento_enviado_usuario]
GO
ALTER TABLE [dbo].[tb_documentos_enviados]  WITH CHECK ADD  CONSTRAINT [fk_documento_enviado_usuario_criacao] FOREIGN KEY([dce_cd_usuario_criacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_documentos_enviados] CHECK CONSTRAINT [fk_documento_enviado_usuario_criacao]
GO
ALTER TABLE [dbo].[tb_documentos_enviados]  WITH CHECK ADD  CONSTRAINT [fk_documento_enviado_usuario_modificacao] FOREIGN KEY([dce_cd_usuario_modificacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_documentos_enviados] CHECK CONSTRAINT [fk_documento_enviado_usuario_modificacao]
GO
ALTER TABLE [dbo].[tb_documentos_tipo_contrato]  WITH CHECK ADD  CONSTRAINT [fk_documentos_tipo_contrato_documentos] FOREIGN KEY([dtc_cd_documento])
REFERENCES [dbo].[tb_documentos] ([dcm_cd_documento])
GO
ALTER TABLE [dbo].[tb_documentos_tipo_contrato] CHECK CONSTRAINT [fk_documentos_tipo_contrato_documentos]
GO
ALTER TABLE [dbo].[tb_documentos_tipo_contrato]  WITH CHECK ADD  CONSTRAINT [fk_documentos_tipo_contrato_tipo_contrato] FOREIGN KEY([dtc_cd_tipo_contrato])
REFERENCES [dbo].[tb_tipo_contrato] ([ttc_cd_tipo_contrato])
GO
ALTER TABLE [dbo].[tb_documentos_tipo_contrato] CHECK CONSTRAINT [fk_documentos_tipo_contrato_tipo_contrato]
GO
ALTER TABLE [dbo].[tb_dra_bases]  WITH CHECK ADD  CONSTRAINT [FK_tb_dra_bases_tb_dra_transportadora] FOREIGN KEY([dab_cd_transportadora])
REFERENCES [dbo].[tb_dra_transportadora] ([tpr_cd_transportadora])
GO
ALTER TABLE [dbo].[tb_dra_bases] CHECK CONSTRAINT [FK_tb_dra_bases_tb_dra_transportadora]
GO
ALTER TABLE [dbo].[tb_dra_reprocessamento]  WITH CHECK ADD  CONSTRAINT [FK_tb_dra_reprocessamento_tb_clientes] FOREIGN KEY([dar_cd_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_dra_reprocessamento] CHECK CONSTRAINT [FK_tb_dra_reprocessamento_tb_clientes]
GO
ALTER TABLE [dbo].[tb_dra_reprocessamento]  WITH CHECK ADD  CONSTRAINT [FK_tb_dra_reprocessamento_tb_lista] FOREIGN KEY([dar_cd_lista_acao])
REFERENCES [dbo].[tb_lista] ([lst_cd_lista])
GO
ALTER TABLE [dbo].[tb_dra_reprocessamento] CHECK CONSTRAINT [FK_tb_dra_reprocessamento_tb_lista]
GO
ALTER TABLE [dbo].[tb_dra_reprocessamento]  WITH CHECK ADD  CONSTRAINT [FK_tb_dra_reprocessamento_tb_lista1] FOREIGN KEY([dar_cd_lista_operacao])
REFERENCES [dbo].[tb_lista] ([lst_cd_lista])
GO
ALTER TABLE [dbo].[tb_dra_reprocessamento] CHECK CONSTRAINT [FK_tb_dra_reprocessamento_tb_lista1]
GO
ALTER TABLE [dbo].[tb_dra_reprocessamento]  WITH CHECK ADD  CONSTRAINT [FK_tb_dra_reprocessamento_tb_lista2] FOREIGN KEY([dar_cd_lista_status])
REFERENCES [dbo].[tb_lista] ([lst_cd_lista])
GO
ALTER TABLE [dbo].[tb_dra_reprocessamento] CHECK CONSTRAINT [FK_tb_dra_reprocessamento_tb_lista2]
GO
ALTER TABLE [dbo].[tb_dra_reprocessamento]  WITH CHECK ADD  CONSTRAINT [FK_tb_dra_reprocessamento_tb_lista3] FOREIGN KEY([dar_cd_lista_transportadora])
REFERENCES [dbo].[tb_lista] ([lst_cd_lista])
GO
ALTER TABLE [dbo].[tb_dra_reprocessamento] CHECK CONSTRAINT [FK_tb_dra_reprocessamento_tb_lista3]
GO
ALTER TABLE [dbo].[tb_dra_tipo_veiculo]  WITH CHECK ADD  CONSTRAINT [FK_tb_dra_tipo_veiculo_tb_dra_classificacao_veiculo] FOREIGN KEY([tvl_cd_classificacao_veiculo])
REFERENCES [dbo].[tb_dra_classificacao_veiculo] ([cvl_cd_classificacao_veiculo])
GO
ALTER TABLE [dbo].[tb_dra_tipo_veiculo] CHECK CONSTRAINT [FK_tb_dra_tipo_veiculo_tb_dra_classificacao_veiculo]
GO
ALTER TABLE [dbo].[tb_dra_transportadora]  WITH CHECK ADD  CONSTRAINT [FK_tb_ml_transportadora_marketplace] FOREIGN KEY([tpr_cd_marketplace])
REFERENCES [dbo].[tb_dra_marketplace] ([mkp_cd_marketplace])
GO
ALTER TABLE [dbo].[tb_dra_transportadora] CHECK CONSTRAINT [FK_tb_ml_transportadora_marketplace]
GO
ALTER TABLE [dbo].[tb_empresas]  WITH CHECK ADD  CONSTRAINT [fk_empresas_cd_cliente] FOREIGN KEY([emp_cd_codigo_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_empresas] CHECK CONSTRAINT [fk_empresas_cd_cliente]
GO
ALTER TABLE [dbo].[tb_empresas]  WITH CHECK ADD  CONSTRAINT [fk_empresas_usr_criacao] FOREIGN KEY([emp_cd_usr_criacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_empresas] CHECK CONSTRAINT [fk_empresas_usr_criacao]
GO
ALTER TABLE [dbo].[tb_envio_boas_vindas_lote]  WITH CHECK ADD  CONSTRAINT [fk_envio_boas_vindas_lote_cliente] FOREIGN KEY([evl_cd_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_envio_boas_vindas_lote] CHECK CONSTRAINT [fk_envio_boas_vindas_lote_cliente]
GO
ALTER TABLE [dbo].[tb_envio_boas_vindas_lote]  WITH CHECK ADD  CONSTRAINT [fk_envio_boas_vindas_lote_usr_criacao] FOREIGN KEY([evl_cd_usr_criacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_envio_boas_vindas_lote] CHECK CONSTRAINT [fk_envio_boas_vindas_lote_usr_criacao]
GO
ALTER TABLE [dbo].[tb_envio_boas_vindas_lote_detalhe]  WITH CHECK ADD  CONSTRAINT [fk_envio_boas_vindas_det_lote] FOREIGN KEY([evld_cd_lote])
REFERENCES [dbo].[tb_envio_boas_vindas_lote] ([evl_cd_lote])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_envio_boas_vindas_lote_detalhe] CHECK CONSTRAINT [fk_envio_boas_vindas_det_lote]
GO
ALTER TABLE [dbo].[tb_envio_relatios]  WITH CHECK ADD  CONSTRAINT [FK_envio_relatios_grupos_whatsapp] FOREIGN KEY([er_cd_grupo_wpp])
REFERENCES [dbo].[tb_grupos_whatsapp] ([tgw_cd_grupos_whatsapp])
GO
ALTER TABLE [dbo].[tb_envio_relatios] CHECK CONSTRAINT [FK_envio_relatios_grupos_whatsapp]
GO
ALTER TABLE [dbo].[tb_envio_relatios]  WITH CHECK ADD  CONSTRAINT [FK_tb_envio_relatios_tb_clientes] FOREIGN KEY([er_cd_codigo_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_envio_relatios] CHECK CONSTRAINT [FK_tb_envio_relatios_tb_clientes]
GO
ALTER TABLE [dbo].[tb_envio_relatios]  WITH CHECK ADD  CONSTRAINT [FK_tb_envio_relatios_tb_relatorios] FOREIGN KEY([er_cd_relatorio])
REFERENCES [dbo].[tb_relatorios] ([rel_cd_relatorio])
GO
ALTER TABLE [dbo].[tb_envio_relatios] CHECK CONSTRAINT [FK_tb_envio_relatios_tb_relatorios]
GO
ALTER TABLE [dbo].[tb_escala_motorista]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_escala_motorista_tb_usuario] FOREIGN KEY([em_cd_motorista])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_escala_motorista] CHECK CONSTRAINT [FK_tb_escala_motorista_tb_usuario]
GO
ALTER TABLE [dbo].[tb_escala_motorista]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_escala_motorista_tb_usuario1] FOREIGN KEY([em_cd_usuario_escala])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_escala_motorista] CHECK CONSTRAINT [FK_tb_escala_motorista_tb_usuario1]
GO
ALTER TABLE [dbo].[tb_fat_aprovacao_motorista]  WITH CHECK ADD  CONSTRAINT [FK_tb_fat_aprovacao_motorista_tb_clientes] FOREIGN KEY([fam_cd_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_fat_aprovacao_motorista] CHECK CONSTRAINT [FK_tb_fat_aprovacao_motorista_tb_clientes]
GO
ALTER TABLE [dbo].[tb_fat_aprovacao_motorista]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_fat_aprovacao_motorista_tb_usuario] FOREIGN KEY([fam_cd_usuario_motorista])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_fat_aprovacao_motorista] CHECK CONSTRAINT [FK_tb_fat_aprovacao_motorista_tb_usuario]
GO
ALTER TABLE [dbo].[tb_fat_aprovacao_motorista]  WITH CHECK ADD  CONSTRAINT [FK_tb_fat_aprovacao_motorista_tb_usuario_aprova] FOREIGN KEY([fam_cd_usuario_aprovacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_fat_aprovacao_motorista] CHECK CONSTRAINT [FK_tb_fat_aprovacao_motorista_tb_usuario_aprova]
GO
ALTER TABLE [dbo].[tb_favoritos]  WITH CHECK ADD  CONSTRAINT [FK_favoritos_controllers] FOREIGN KEY([ctr_cd_controller])
REFERENCES [dbo].[tb_controller] ([ctr_cd_controller])
GO
ALTER TABLE [dbo].[tb_favoritos] CHECK CONSTRAINT [FK_favoritos_controllers]
GO
ALTER TABLE [dbo].[tb_favoritos]  WITH CHECK ADD  CONSTRAINT [FK_favoritos_usuarios] FOREIGN KEY([usr_cd_usuario])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_favoritos] CHECK CONSTRAINT [FK_favoritos_usuarios]
GO
ALTER TABLE [dbo].[tb_feriados]  WITH CHECK ADD  CONSTRAINT [fk_feriados_cod_cliente] FOREIGN KEY([tfd_cd_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_feriados] CHECK CONSTRAINT [fk_feriados_cod_cliente]
GO
ALTER TABLE [dbo].[tb_fin_base_frete_adicional]  WITH CHECK ADD  CONSTRAINT [FK_tb_fin_base_frete_adicional_tb_dra_tipo_veiculo] FOREIGN KEY([bfa_cd_tipo_veiculo])
REFERENCES [dbo].[tb_dra_tipo_veiculo] ([tvl_cd_tipo_veiculo])
GO
ALTER TABLE [dbo].[tb_fin_base_frete_adicional] CHECK CONSTRAINT [FK_tb_fin_base_frete_adicional_tb_dra_tipo_veiculo]
GO
ALTER TABLE [dbo].[tb_fin_base_frete_adicional]  WITH CHECK ADD  CONSTRAINT [FK_tb_fin_base_frete_adicional_tb_fin_tipo_calculo] FOREIGN KEY([bfa_tipo_adicional_domingo])
REFERENCES [dbo].[tb_fin_tipo_calculo] ([ftc_cd_tipo_calculo])
GO
ALTER TABLE [dbo].[tb_fin_base_frete_adicional] CHECK CONSTRAINT [FK_tb_fin_base_frete_adicional_tb_fin_tipo_calculo]
GO
ALTER TABLE [dbo].[tb_fin_base_frete_adicional]  WITH CHECK ADD  CONSTRAINT [FK_tb_fin_base_frete_adicional_tb_fin_tipo_calculo1] FOREIGN KEY([bfa_tipo_adicional_ciclo_pm])
REFERENCES [dbo].[tb_fin_tipo_calculo] ([ftc_cd_tipo_calculo])
GO
ALTER TABLE [dbo].[tb_fin_base_frete_adicional] CHECK CONSTRAINT [FK_tb_fin_base_frete_adicional_tb_fin_tipo_calculo1]
GO
ALTER TABLE [dbo].[tb_fin_base_frete_adicional_motorista]  WITH CHECK ADD  CONSTRAINT [fk_base_frete_adicional_motorista_bfa_cd_tipo_contrato] FOREIGN KEY([bfa_cd_tipo_contrato])
REFERENCES [dbo].[tb_tipo_contrato] ([ttc_cd_tipo_contrato])
GO
ALTER TABLE [dbo].[tb_fin_base_frete_adicional_motorista] CHECK CONSTRAINT [fk_base_frete_adicional_motorista_bfa_cd_tipo_contrato]
GO
ALTER TABLE [dbo].[tb_fin_base_frete_adicional_motorista]  WITH CHECK ADD  CONSTRAINT [FK_tb_fin_base_frete_adicional_motorista_tb_dra_tipo_veiculo] FOREIGN KEY([bfa_cd_tipo_veiculo])
REFERENCES [dbo].[tb_dra_tipo_veiculo] ([tvl_cd_tipo_veiculo])
GO
ALTER TABLE [dbo].[tb_fin_base_frete_adicional_motorista] CHECK CONSTRAINT [FK_tb_fin_base_frete_adicional_motorista_tb_dra_tipo_veiculo]
GO
ALTER TABLE [dbo].[tb_fin_base_frete_adicional_motorista]  WITH CHECK ADD  CONSTRAINT [FK_tb_fin_base_frete_adicional_motorista_tb_fin_tipo_calculo] FOREIGN KEY([bfa_tipo_adicional_domingo])
REFERENCES [dbo].[tb_fin_tipo_calculo] ([ftc_cd_tipo_calculo])
GO
ALTER TABLE [dbo].[tb_fin_base_frete_adicional_motorista] CHECK CONSTRAINT [FK_tb_fin_base_frete_adicional_motorista_tb_fin_tipo_calculo]
GO
ALTER TABLE [dbo].[tb_fin_base_frete_adicional_motorista]  WITH CHECK ADD  CONSTRAINT [FK_tb_fin_base_frete_adicional_motorista_tb_fin_tipo_calculo1] FOREIGN KEY([bfa_tipo_adicional_ciclo_pm])
REFERENCES [dbo].[tb_fin_tipo_calculo] ([ftc_cd_tipo_calculo])
GO
ALTER TABLE [dbo].[tb_fin_base_frete_adicional_motorista] CHECK CONSTRAINT [FK_tb_fin_base_frete_adicional_motorista_tb_fin_tipo_calculo1]
GO
ALTER TABLE [dbo].[tb_fin_base_frete_adicional_motorista_parada]  WITH CHECK ADD  CONSTRAINT [FK_tb_fin_base_frete_adicional_motorista_parada] FOREIGN KEY([bfa_cd_adicional_motorista])
REFERENCES [dbo].[tb_fin_base_frete_adicional_motorista] ([bfa_cd_base_frete_adicional_motorista])
GO
ALTER TABLE [dbo].[tb_fin_base_frete_adicional_motorista_parada] CHECK CONSTRAINT [FK_tb_fin_base_frete_adicional_motorista_parada]
GO
ALTER TABLE [dbo].[tb_fin_base_frete_adicional_parada]  WITH CHECK ADD  CONSTRAINT [FK_tb_fin_base_frete_adicional_parada] FOREIGN KEY([bfa_cd_frete_adicional])
REFERENCES [dbo].[tb_fin_base_frete_adicional] ([bfa_cd_base_frete_adicional])
GO
ALTER TABLE [dbo].[tb_fin_base_frete_adicional_parada] CHECK CONSTRAINT [FK_tb_fin_base_frete_adicional_parada]
GO
ALTER TABLE [dbo].[tb_fin_base_frete_motorista]  WITH CHECK ADD  CONSTRAINT [fk_base_frete_motorista_bmf_cd_tipo_contrato] FOREIGN KEY([bmf_cd_tipo_contrato])
REFERENCES [dbo].[tb_tipo_contrato] ([ttc_cd_tipo_contrato])
GO
ALTER TABLE [dbo].[tb_fin_base_frete_motorista] CHECK CONSTRAINT [fk_base_frete_motorista_bmf_cd_tipo_contrato]
GO
ALTER TABLE [dbo].[tb_fin_base_frete_motorista]  WITH CHECK ADD  CONSTRAINT [FK_tb_fin_base_frete_motorista_tb_dra_tipo_veiculo] FOREIGN KEY([bfm_cd_tipo_veiculo])
REFERENCES [dbo].[tb_dra_tipo_veiculo] ([tvl_cd_tipo_veiculo])
GO
ALTER TABLE [dbo].[tb_fin_base_frete_motorista] CHECK CONSTRAINT [FK_tb_fin_base_frete_motorista_tb_dra_tipo_veiculo]
GO
ALTER TABLE [dbo].[tb_fin_base_frete_motorista]  WITH CHECK ADD  CONSTRAINT [FK_tb_fin_base_frete_motorista_tb_lista_criterio_faixa] FOREIGN KEY([bfm_cd_criterio_faixa])
REFERENCES [dbo].[tb_lista] ([lst_cd_lista])
GO
ALTER TABLE [dbo].[tb_fin_base_frete_motorista] CHECK CONSTRAINT [FK_tb_fin_base_frete_motorista_tb_lista_criterio_faixa]
GO
ALTER TABLE [dbo].[tb_fin_base_frete_motorista]  WITH CHECK ADD  CONSTRAINT [FK_tb_fin_base_frete_motorista_tb_lista_criterio_faixa2] FOREIGN KEY([bfm_cd_criterio_faixa2])
REFERENCES [dbo].[tb_lista] ([lst_cd_lista])
GO
ALTER TABLE [dbo].[tb_fin_base_frete_motorista] CHECK CONSTRAINT [FK_tb_fin_base_frete_motorista_tb_lista_criterio_faixa2]
GO
ALTER TABLE [dbo].[tb_fin_base_frete_motorista]  WITH CHECK ADD  CONSTRAINT [FK_tb_regra_sla_tb_fin_base_frete_motorista] FOREIGN KEY([bfm_cd_sla])
REFERENCES [dbo].[tb_regra_sla] ([id])
GO
ALTER TABLE [dbo].[tb_fin_base_frete_motorista] CHECK CONSTRAINT [FK_tb_regra_sla_tb_fin_base_frete_motorista]
GO
ALTER TABLE [dbo].[tb_fin_base_frete_motorista_cte]  WITH CHECK ADD  CONSTRAINT [FK_tb_fin_base_frete_motorista_cte_cliente_transportadora] FOREIGN KEY([fmc_cd_cliente_transportadora])
REFERENCES [dbo].[tb_lista] ([lst_cd_lista])
GO
ALTER TABLE [dbo].[tb_fin_base_frete_motorista_cte] CHECK CONSTRAINT [FK_tb_fin_base_frete_motorista_cte_cliente_transportadora]
GO
ALTER TABLE [dbo].[tb_fin_base_frete_motorista_cte]  WITH CHECK ADD  CONSTRAINT [FK_tb_fin_base_frete_motorista_cte_contrato] FOREIGN KEY([fmc_cd_tipo_contrato])
REFERENCES [dbo].[tb_tipo_contrato] ([ttc_cd_tipo_contrato])
GO
ALTER TABLE [dbo].[tb_fin_base_frete_motorista_cte] CHECK CONSTRAINT [FK_tb_fin_base_frete_motorista_cte_contrato]
GO
ALTER TABLE [dbo].[tb_fin_base_frete_transportadora]  WITH CHECK ADD  CONSTRAINT [FK_tb_fin_base_frete_transportadora_tb_dra_tipo_veiculo] FOREIGN KEY([bft_cd_tipo_veiculo])
REFERENCES [dbo].[tb_dra_tipo_veiculo] ([tvl_cd_tipo_veiculo])
GO
ALTER TABLE [dbo].[tb_fin_base_frete_transportadora] CHECK CONSTRAINT [FK_tb_fin_base_frete_transportadora_tb_dra_tipo_veiculo]
GO
ALTER TABLE [dbo].[tb_fin_base_km_trevo]  WITH CHECK ADD  CONSTRAINT [FK_tb_fin_base_km_trevo_tb_dra_transportadora] FOREIGN KEY([bkt_cd_transportadora])
REFERENCES [dbo].[tb_dra_transportadora] ([tpr_cd_transportadora])
GO
ALTER TABLE [dbo].[tb_fin_base_km_trevo] CHECK CONSTRAINT [FK_tb_fin_base_km_trevo_tb_dra_transportadora]
GO
ALTER TABLE [dbo].[tb_fin_definie_cidade_distrito]  WITH CHECK ADD  CONSTRAINT [fk_fcd_cd_base] FOREIGN KEY([fcd_cd_Base])
REFERENCES [dbo].[tb_bases] ([bss_cd_base])
GO
ALTER TABLE [dbo].[tb_fin_definie_cidade_distrito] CHECK CONSTRAINT [fk_fcd_cd_base]
GO
ALTER TABLE [dbo].[tb_fin_definie_cidade_distrito]  WITH CHECK ADD  CONSTRAINT [fk_fcd_cd_cidade] FOREIGN KEY([fcd_cd_cidade])
REFERENCES [dbo].[tb_codigos_cidades] ([cid_cd_cidade])
GO
ALTER TABLE [dbo].[tb_fin_definie_cidade_distrito] CHECK CONSTRAINT [fk_fcd_cd_cidade]
GO
ALTER TABLE [dbo].[tb_fin_definie_cidade_distrito]  WITH CHECK ADD  CONSTRAINT [fk_fcd_cd_cliente] FOREIGN KEY([fcd_cd_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_fin_definie_cidade_distrito] CHECK CONSTRAINT [fk_fcd_cd_cliente]
GO
ALTER TABLE [dbo].[tb_fin_definie_cidade_distrito]  WITH CHECK ADD  CONSTRAINT [fk_fcd_cd_distrito] FOREIGN KEY([fcd_cd_distrito])
REFERENCES [dbo].[tb_fin_distritos_cadastrados] ([IdDistrito])
GO
ALTER TABLE [dbo].[tb_fin_definie_cidade_distrito] CHECK CONSTRAINT [fk_fcd_cd_distrito]
GO
ALTER TABLE [dbo].[tb_fin_definie_cidade_distrito]  WITH CHECK ADD  CONSTRAINT [fk_fcd_cd_estado] FOREIGN KEY([fcd_cd_estado])
REFERENCES [dbo].[tb_estados_ibge] ([id])
GO
ALTER TABLE [dbo].[tb_fin_definie_cidade_distrito] CHECK CONSTRAINT [fk_fcd_cd_estado]
GO
ALTER TABLE [dbo].[tb_fin_descontos_motoristas]  WITH CHECK ADD  CONSTRAINT [FK_tb_fin_descontos_motoristas_transportadora] FOREIGN KEY([IdTransportadora])
REFERENCES [dbo].[tb_dra_transportadora] ([tpr_cd_transportadora])
GO
ALTER TABLE [dbo].[tb_fin_descontos_motoristas] CHECK CONSTRAINT [FK_tb_fin_descontos_motoristas_transportadora]
GO
ALTER TABLE [dbo].[tb_fin_fat_cliente]  WITH CHECK ADD  CONSTRAINT [FK_tb_fin_fat_cliente_tb_cliente] FOREIGN KEY([fcl_cd_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_fin_fat_cliente] CHECK CONSTRAINT [FK_tb_fin_fat_cliente_tb_cliente]
GO
ALTER TABLE [dbo].[tb_fin_faturas]  WITH CHECK ADD  CONSTRAINT [FK_tb_fin_faturas_tb_fin_fat_cliente] FOREIGN KEY([fat_cd_fat_cliente])
REFERENCES [dbo].[tb_fin_fat_cliente] ([fcl_cd_fat_cliente])
GO
ALTER TABLE [dbo].[tb_fin_faturas] CHECK CONSTRAINT [FK_tb_fin_faturas_tb_fin_fat_cliente]
GO
ALTER TABLE [dbo].[tb_fin_fm_prefatura]  WITH CHECK ADD  CONSTRAINT [FK_tb_fin_fm_prefatura_transportadora] FOREIGN KEY([IdTransportadora])
REFERENCES [dbo].[tb_dra_transportadora] ([tpr_cd_transportadora])
GO
ALTER TABLE [dbo].[tb_fin_fm_prefatura] CHECK CONSTRAINT [FK_tb_fin_fm_prefatura_transportadora]
GO
ALTER TABLE [dbo].[tb_fin_mo_prefatura]  WITH CHECK ADD  CONSTRAINT [FK_tb_fin_mo_prefatura_transportadora] FOREIGN KEY([IdTransportadora])
REFERENCES [dbo].[tb_dra_transportadora] ([tpr_cd_transportadora])
GO
ALTER TABLE [dbo].[tb_fin_mo_prefatura] CHECK CONSTRAINT [FK_tb_fin_mo_prefatura_transportadora]
GO
ALTER TABLE [dbo].[tb_fin_prefatura]  WITH CHECK ADD  CONSTRAINT [FK_tb_fin_prefatura_transportadora] FOREIGN KEY([IdTransportadora])
REFERENCES [dbo].[tb_dra_transportadora] ([tpr_cd_transportadora])
GO
ALTER TABLE [dbo].[tb_fin_prefatura] CHECK CONSTRAINT [FK_tb_fin_prefatura_transportadora]
GO
ALTER TABLE [dbo].[tb_fin_prefatura_upload]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_fin_prefatura_upload_transportadora] FOREIGN KEY([IdTransportadora])
REFERENCES [dbo].[tb_dra_transportadora] ([tpr_cd_transportadora])
GO
ALTER TABLE [dbo].[tb_fin_prefatura_upload] CHECK CONSTRAINT [FK_tb_fin_prefatura_upload_transportadora]
GO
ALTER TABLE [dbo].[tb_fin_salarios_profissionais]  WITH CHECK ADD  CONSTRAINT [fk_fin_salarios_profissionais_user] FOREIGN KEY([tsp_cd_usuario])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_fin_salarios_profissionais] CHECK CONSTRAINT [fk_fin_salarios_profissionais_user]
GO
ALTER TABLE [dbo].[tb_formularios]  WITH CHECK ADD  CONSTRAINT [fk_cli_cd_codigo_cliente] FOREIGN KEY([cli_cd_codigo_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_formularios] CHECK CONSTRAINT [fk_cli_cd_codigo_cliente]
GO
ALTER TABLE [dbo].[tb_formularios]  WITH CHECK ADD  CONSTRAINT [fk_frm_usr_criacao] FOREIGN KEY([frm_cd_usr_criacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_formularios] CHECK CONSTRAINT [fk_frm_usr_criacao]
GO
ALTER TABLE [dbo].[tb_formularios]  WITH CHECK ADD  CONSTRAINT [fk_frm_usr_modificacao] FOREIGN KEY([frm_cd_usr_modificacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_formularios] CHECK CONSTRAINT [fk_frm_usr_modificacao]
GO
ALTER TABLE [dbo].[tb_formularios_respostas]  WITH CHECK ADD  CONSTRAINT [fk_form_cli_cd_codigo_cliente] FOREIGN KEY([cli_cd_codigo_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_formularios_respostas] CHECK CONSTRAINT [fk_form_cli_cd_codigo_cliente]
GO
ALTER TABLE [dbo].[tb_formularios_respostas]  WITH CHECK ADD  CONSTRAINT [fk_frr_cd_formulario] FOREIGN KEY([frr_cd_formulario])
REFERENCES [dbo].[tb_formularios] ([frm_cd_formulario])
GO
ALTER TABLE [dbo].[tb_formularios_respostas] CHECK CONSTRAINT [fk_frr_cd_formulario]
GO
ALTER TABLE [dbo].[tb_gr_fichas]  WITH CHECK ADD  CONSTRAINT [fk_gr_validacao_fichas_cliente] FOREIGN KEY([grv_cd_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_gr_fichas] CHECK CONSTRAINT [fk_gr_validacao_fichas_cliente]
GO
ALTER TABLE [dbo].[tb_gr_veiculos_ficha]  WITH CHECK ADD  CONSTRAINT [fk_gr_veiculos_ficha_veiculo] FOREIGN KEY([grv_cd_veiculo])
REFERENCES [dbo].[tb_gr_veiculos] ([grv_cd_veiculo])
GO
ALTER TABLE [dbo].[tb_gr_veiculos_ficha] CHECK CONSTRAINT [fk_gr_veiculos_ficha_veiculo]
GO
ALTER TABLE [dbo].[tb_grupos_whatsapp]  WITH CHECK ADD  CONSTRAINT [FK_grupos_whatsapp_tb_clientes] FOREIGN KEY([tgw_cd_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_grupos_whatsapp] CHECK CONSTRAINT [FK_grupos_whatsapp_tb_clientes]
GO
ALTER TABLE [dbo].[tb_historico_alarmes]  WITH CHECK ADD FOREIGN KEY([IdAlarme])
REFERENCES [dbo].[tb_alarmes] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_imp_grupo]  WITH CHECK ADD  CONSTRAINT [FK_tb_imp_grupo_cliente] FOREIGN KEY([cli_cd_codigo_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_imp_grupo] CHECK CONSTRAINT [FK_tb_imp_grupo_cliente]
GO
ALTER TABLE [dbo].[tb_imp_importador]  WITH CHECK ADD  CONSTRAINT [FK_tb_imp_importador_cliente] FOREIGN KEY([cli_cd_codigo_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_imp_importador] CHECK CONSTRAINT [FK_tb_imp_importador_cliente]
GO
ALTER TABLE [dbo].[tb_imp_importador]  WITH CHECK ADD  CONSTRAINT [FK_tb_imp_importador_grupo] FOREIGN KEY([grp_cd_grupo])
REFERENCES [dbo].[tb_imp_grupo] ([grp_cd_grupo])
GO
ALTER TABLE [dbo].[tb_imp_importador] CHECK CONSTRAINT [FK_tb_imp_importador_grupo]
GO
ALTER TABLE [dbo].[tb_imp_importador]  WITH CHECK ADD  CONSTRAINT [FK_tb_imp_importador_usr_criacao] FOREIGN KEY([usr_cd_usuario_criacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_imp_importador] CHECK CONSTRAINT [FK_tb_imp_importador_usr_criacao]
GO
ALTER TABLE [dbo].[tb_imp_importador_coluna]  WITH CHECK ADD  CONSTRAINT [FK_tb_imp_importador_coluna_importador] FOREIGN KEY([imp_cd_importador])
REFERENCES [dbo].[tb_imp_importador] ([imp_cd_importador])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_imp_importador_coluna] CHECK CONSTRAINT [FK_tb_imp_importador_coluna_importador]
GO
ALTER TABLE [dbo].[tb_imp_log]  WITH CHECK ADD  CONSTRAINT [FK_tb_imp_log_cliente] FOREIGN KEY([cli_cd_codigo_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_imp_log] CHECK CONSTRAINT [FK_tb_imp_log_cliente]
GO
ALTER TABLE [dbo].[tb_imp_log]  WITH CHECK ADD  CONSTRAINT [FK_tb_imp_log_importador] FOREIGN KEY([imp_cd_importador])
REFERENCES [dbo].[tb_imp_importador] ([imp_cd_importador])
GO
ALTER TABLE [dbo].[tb_imp_log] CHECK CONSTRAINT [FK_tb_imp_log_importador]
GO
ALTER TABLE [dbo].[tb_imp_log]  WITH CHECK ADD  CONSTRAINT [FK_tb_imp_log_status] FOREIGN KEY([ist_cd_status])
REFERENCES [dbo].[tb_imp_status] ([ist_cd_status])
GO
ALTER TABLE [dbo].[tb_imp_log] CHECK CONSTRAINT [FK_tb_imp_log_status]
GO
ALTER TABLE [dbo].[tb_imp_log]  WITH CHECK ADD  CONSTRAINT [FK_tb_imp_log_usuario] FOREIGN KEY([usr_cd_usuario])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_imp_log] CHECK CONSTRAINT [FK_tb_imp_log_usuario]
GO
ALTER TABLE [dbo].[tb_imp_log_coluna_erro]  WITH CHECK ADD  CONSTRAINT [FK_tb_imp_log_coluna_erro_log] FOREIGN KEY([ilg_cd_log])
REFERENCES [dbo].[tb_imp_log] ([ilg_cd_log])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_imp_log_coluna_erro] CHECK CONSTRAINT [FK_tb_imp_log_coluna_erro_log]
GO
ALTER TABLE [dbo].[tb_imp_log_edicao]  WITH CHECK ADD  CONSTRAINT [FK_tb_imp_log_edicao_cliente] FOREIGN KEY([cli_cd_codigo_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_imp_log_edicao] CHECK CONSTRAINT [FK_tb_imp_log_edicao_cliente]
GO
ALTER TABLE [dbo].[tb_imp_log_edicao]  WITH CHECK ADD  CONSTRAINT [FK_tb_imp_log_edicao_log] FOREIGN KEY([ilg_cd_log])
REFERENCES [dbo].[tb_imp_log] ([ilg_cd_log])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_imp_log_edicao] CHECK CONSTRAINT [FK_tb_imp_log_edicao_log]
GO
ALTER TABLE [dbo].[tb_imp_log_edicao]  WITH CHECK ADD  CONSTRAINT [FK_tb_imp_log_edicao_usuario] FOREIGN KEY([usr_cd_usuario])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_imp_log_edicao] CHECK CONSTRAINT [FK_tb_imp_log_edicao_usuario]
GO
ALTER TABLE [dbo].[tb_imp_log_execucao_script]  WITH CHECK ADD  CONSTRAINT [FK_tb_imp_log_execucao_script_log] FOREIGN KEY([ilg_cd_log])
REFERENCES [dbo].[tb_imp_log] ([ilg_cd_log])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_imp_log_execucao_script] CHECK CONSTRAINT [FK_tb_imp_log_execucao_script_log]
GO
ALTER TABLE [dbo].[tb_indicadores_diarios]  WITH CHECK ADD  CONSTRAINT [fk_indicadores_diarios_cd_transportadora] FOREIGN KEY([ind_cd_transportadora])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_indicadores_diarios] CHECK CONSTRAINT [fk_indicadores_diarios_cd_transportadora]
GO
ALTER TABLE [dbo].[tb_indicadores_diarios]  WITH CHECK ADD  CONSTRAINT [fk_indicadores_diarios_cd_usuario] FOREIGN KEY([ind_cd_usuario])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_indicadores_diarios] CHECK CONSTRAINT [fk_indicadores_diarios_cd_usuario]
GO
ALTER TABLE [dbo].[tb_indisponibilidade_motorista]  WITH CHECK ADD  CONSTRAINT [FK_indisponibilidade_tb_lista_motivo] FOREIGN KEY([idp_cd_motivo])
REFERENCES [dbo].[tb_lista] ([lst_cd_lista])
GO
ALTER TABLE [dbo].[tb_indisponibilidade_motorista] CHECK CONSTRAINT [FK_indisponibilidade_tb_lista_motivo]
GO
ALTER TABLE [dbo].[tb_indisponibilidade_motorista]  WITH CHECK ADD  CONSTRAINT [FK_indisponibilidade_tb_usuario] FOREIGN KEY([idp_cd_usuario])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_indisponibilidade_motorista] CHECK CONSTRAINT [FK_indisponibilidade_tb_usuario]
GO
ALTER TABLE [dbo].[tb_indisponibilidade_motorista]  WITH CHECK ADD  CONSTRAINT [FK_indisponibilidade_usuario_criacao] FOREIGN KEY([idp_cd_usuario_criacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_indisponibilidade_motorista] CHECK CONSTRAINT [FK_indisponibilidade_usuario_criacao]
GO
ALTER TABLE [dbo].[tb_indisponibilidade_motorista]  WITH CHECK ADD  CONSTRAINT [FK_indisponibilidade_usuario_modificacao] FOREIGN KEY([idp_cd_usuario_modificacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_indisponibilidade_motorista] CHECK CONSTRAINT [FK_indisponibilidade_usuario_modificacao]
GO
ALTER TABLE [dbo].[tb_info_page]  WITH CHECK ADD  CONSTRAINT [fk_inp_usr_criacao] FOREIGN KEY([inp_cd_usuario_criacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_info_page] CHECK CONSTRAINT [fk_inp_usr_criacao]
GO
ALTER TABLE [dbo].[tb_info_page]  WITH CHECK ADD  CONSTRAINT [fk_inp_usr_modificacao] FOREIGN KEY([inp_cd_usuario_modificacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_info_page] CHECK CONSTRAINT [fk_inp_usr_modificacao]
GO
ALTER TABLE [dbo].[tb_instancias_token_wp]  WITH CHECK ADD FOREIGN KEY([titw_cd_intancia_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_integracao_flex_eventos]  WITH CHECK ADD  CONSTRAINT [FK_tb_integracao_flex_eventos_codigo_cliente] FOREIGN KEY([iev_cd_codigo_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_integracao_flex_eventos] CHECK CONSTRAINT [FK_tb_integracao_flex_eventos_codigo_cliente]
GO
ALTER TABLE [dbo].[tb_integracao_flex_logs]  WITH CHECK ADD  CONSTRAINT [FK_tb_integracao_flex_logs_codigo_cliente] FOREIGN KEY([inf_cd_codigo_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_integracao_flex_logs] CHECK CONSTRAINT [FK_tb_integracao_flex_logs_codigo_cliente]
GO
ALTER TABLE [dbo].[tb_integracao_flex_parametros]  WITH CHECK ADD  CONSTRAINT [fk_integracao_flex_par_client] FOREIGN KEY([ifp_cd_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_integracao_flex_parametros] CHECK CONSTRAINT [fk_integracao_flex_par_client]
GO
ALTER TABLE [dbo].[tb_integracao_flex_parametros]  WITH CHECK ADD  CONSTRAINT [fk_integracao_flex_par_tipo_veiculo] FOREIGN KEY([ifp_cd_tipo_veiculo])
REFERENCES [dbo].[tb_dra_tipo_veiculo] ([tvl_cd_tipo_veiculo])
GO
ALTER TABLE [dbo].[tb_integracao_flex_parametros] CHECK CONSTRAINT [fk_integracao_flex_par_tipo_veiculo]
GO
ALTER TABLE [dbo].[tb_integracao_flex_parametros]  WITH CHECK ADD  CONSTRAINT [FK_tb_integracao_flex_parametros_tb_bases] FOREIGN KEY([ifp_cd_base])
REFERENCES [dbo].[tb_bases] ([bss_cd_base])
GO
ALTER TABLE [dbo].[tb_integracao_flex_parametros] CHECK CONSTRAINT [FK_tb_integracao_flex_parametros_tb_bases]
GO
ALTER TABLE [dbo].[tb_lancamentos_manuais]  WITH CHECK ADD  CONSTRAINT [fk_tb_lancamentos_manuais_tb_lista] FOREIGN KEY([tlm_cd_cliente_transportadora])
REFERENCES [dbo].[tb_lista] ([lst_cd_lista])
GO
ALTER TABLE [dbo].[tb_lancamentos_manuais] CHECK CONSTRAINT [fk_tb_lancamentos_manuais_tb_lista]
GO
ALTER TABLE [dbo].[tb_lancamentos_manuais_importacao_log]  WITH CHECK ADD  CONSTRAINT [fk_lmi_cliente] FOREIGN KEY([lmi_cd_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_lancamentos_manuais_importacao_log] CHECK CONSTRAINT [fk_lmi_cliente]
GO
ALTER TABLE [dbo].[tb_lancamentos_manuais_importacao_log]  WITH CHECK ADD  CONSTRAINT [fk_lmi_usuario_execucao] FOREIGN KEY([lmi_cd_usuario_execucao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_lancamentos_manuais_importacao_log] CHECK CONSTRAINT [fk_lmi_usuario_execucao]
GO
ALTER TABLE [dbo].[tb_log_aprovacao_motorista]  WITH CHECK ADD  CONSTRAINT [fk_log_aprovacao_motorista_cliente] FOREIGN KEY([lam_cd_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_log_aprovacao_motorista] CHECK CONSTRAINT [fk_log_aprovacao_motorista_cliente]
GO
ALTER TABLE [dbo].[tb_log_aprovacao_motorista]  WITH CHECK ADD  CONSTRAINT [fk_log_aprovacao_motorista_usuario] FOREIGN KEY([lam_cd_usuario])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_log_aprovacao_motorista] CHECK CONSTRAINT [fk_log_aprovacao_motorista_usuario]
GO
ALTER TABLE [dbo].[tb_log_importacao_lancamentos_manuais]  WITH CHECK ADD  CONSTRAINT [fk_log_importacao_cliente] FOREIGN KEY([lim_cd_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_log_importacao_lancamentos_manuais] CHECK CONSTRAINT [fk_log_importacao_cliente]
GO
ALTER TABLE [dbo].[tb_log_importacao_lancamentos_manuais]  WITH CHECK ADD  CONSTRAINT [fk_log_importacao_lancamento_manual] FOREIGN KEY([lim_cd_lancamento_manual])
REFERENCES [dbo].[tb_lancamentos_manuais] ([tlm_cd_lancamento_manual])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[tb_log_importacao_lancamentos_manuais] CHECK CONSTRAINT [fk_log_importacao_lancamento_manual]
GO
ALTER TABLE [dbo].[tb_log_importacao_lancamentos_manuais]  WITH CHECK ADD  CONSTRAINT [fk_log_importacao_usuario_criacao] FOREIGN KEY([lim_cd_usuario_criacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_log_importacao_lancamentos_manuais] CHECK CONSTRAINT [fk_log_importacao_usuario_criacao]
GO
ALTER TABLE [dbo].[tb_log_importacao_lancamentos_manuais]  WITH CHECK ADD  CONSTRAINT [fk_log_importacao_usuario_execucao] FOREIGN KEY([lim_cd_usuario_execucao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_log_importacao_lancamentos_manuais] CHECK CONSTRAINT [fk_log_importacao_usuario_execucao]
GO
ALTER TABLE [dbo].[tb_log_importacao_lancamentos_manuais]  WITH CHECK ADD  CONSTRAINT [fk_log_importacao_usuario_modificacao] FOREIGN KEY([lim_cd_usuario_modificacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_log_importacao_lancamentos_manuais] CHECK CONSTRAINT [fk_log_importacao_usuario_modificacao]
GO
ALTER TABLE [dbo].[tb_log_importacao_lancamentos_manuais_resultado]  WITH CHECK ADD  CONSTRAINT [fk_log_resultado_log_importacao] FOREIGN KEY([lir_cd_log_importacao])
REFERENCES [dbo].[tb_log_importacao_lancamentos_manuais] ([lim_cd_log_importacao])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_log_importacao_lancamentos_manuais_resultado] CHECK CONSTRAINT [fk_log_resultado_log_importacao]
GO
ALTER TABLE [dbo].[tb_log_rotinas]  WITH CHECK ADD  CONSTRAINT [fk_log_rotinas_cod_usuario] FOREIGN KEY([lrt_cd_usuario])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_log_rotinas] CHECK CONSTRAINT [fk_log_rotinas_cod_usuario]
GO
ALTER TABLE [dbo].[tb_log_rotinas]  WITH CHECK ADD  CONSTRAINT [FK_tb_log_rotinas_tb_rotina_status] FOREIGN KEY([lrt_rts_cd_rotina_status])
REFERENCES [dbo].[tb_rotina_status] ([rts_cd_rotina_status])
GO
ALTER TABLE [dbo].[tb_log_rotinas] CHECK CONSTRAINT [FK_tb_log_rotinas_tb_rotina_status]
GO
ALTER TABLE [dbo].[tb_log_rotinas]  WITH CHECK ADD  CONSTRAINT [FK_tb_log_rotinas_tb_rotinas] FOREIGN KEY([lrt_cd_rotina])
REFERENCES [dbo].[tb_rotinas] ([rtn_cd_rotina])
GO
ALTER TABLE [dbo].[tb_log_rotinas] CHECK CONSTRAINT [FK_tb_log_rotinas_tb_rotinas]
GO
ALTER TABLE [dbo].[tb_log_status_motorista_nfs]  WITH CHECK ADD  CONSTRAINT [fk_log_status_motorista_nfs_nota_fiscal] FOREIGN KEY([lsm_cd_motorista_nfs])
REFERENCES [dbo].[tb_pag_espelhos] ([mtn_cd_motorista_nfs])
GO
ALTER TABLE [dbo].[tb_log_status_motorista_nfs] CHECK CONSTRAINT [fk_log_status_motorista_nfs_nota_fiscal]
GO
ALTER TABLE [dbo].[tb_log_status_motorista_nfs]  WITH CHECK ADD  CONSTRAINT [fk_log_status_motorista_nfs_status_anterior] FOREIGN KEY([lsm_cd_status_anterior])
REFERENCES [dbo].[tb_lista] ([lst_cd_lista])
GO
ALTER TABLE [dbo].[tb_log_status_motorista_nfs] CHECK CONSTRAINT [fk_log_status_motorista_nfs_status_anterior]
GO
ALTER TABLE [dbo].[tb_log_status_motorista_nfs]  WITH CHECK ADD  CONSTRAINT [fk_log_status_motorista_nfs_status_atual] FOREIGN KEY([lsm_cd_status_atual])
REFERENCES [dbo].[tb_lista] ([lst_cd_lista])
GO
ALTER TABLE [dbo].[tb_log_status_motorista_nfs] CHECK CONSTRAINT [fk_log_status_motorista_nfs_status_atual]
GO
ALTER TABLE [dbo].[tb_log_status_motorista_nfs]  WITH CHECK ADD  CONSTRAINT [fk_log_status_motorista_nfs_usuario] FOREIGN KEY([lsm_cd_usuario])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_log_status_motorista_nfs] CHECK CONSTRAINT [fk_log_status_motorista_nfs_usuario]
GO
ALTER TABLE [dbo].[tb_logistics_fat_motoristas_faixa]  WITH CHECK ADD  CONSTRAINT [fk_lfm_usr_criacao] FOREIGN KEY([lfm_cd_usr_criacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_logistics_fat_motoristas_faixa] CHECK CONSTRAINT [fk_lfm_usr_criacao]
GO
ALTER TABLE [dbo].[tb_logistics_fat_motoristas_faixa]  WITH CHECK ADD  CONSTRAINT [fk_lfm_usr_modificacao] FOREIGN KEY([lfm_cd_usr_modificacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_logistics_fat_motoristas_faixa] CHECK CONSTRAINT [fk_lfm_usr_modificacao]
GO
ALTER TABLE [dbo].[tb_logs]  WITH CHECK ADD  CONSTRAINT [FK_tb_logs_tb_tipo_log] FOREIGN KEY([log_cd_tipo])
REFERENCES [dbo].[tb_tipo_log] ([lgt_cd_tipo])
GO
ALTER TABLE [dbo].[tb_logs] CHECK CONSTRAINT [FK_tb_logs_tb_tipo_log]
GO
ALTER TABLE [dbo].[tb_logs_acessos]  WITH CHECK ADD  CONSTRAINT [FK_logs_acessos_actions] FOREIGN KEY([act_cd_action])
REFERENCES [dbo].[tb_action] ([act_cd_action])
GO
ALTER TABLE [dbo].[tb_logs_acessos] CHECK CONSTRAINT [FK_logs_acessos_actions]
GO
ALTER TABLE [dbo].[tb_logs_acessos]  WITH CHECK ADD  CONSTRAINT [FK_logs_acessos_controllers] FOREIGN KEY([ctr_cd_controller])
REFERENCES [dbo].[tb_controller] ([ctr_cd_controller])
GO
ALTER TABLE [dbo].[tb_logs_acessos] CHECK CONSTRAINT [FK_logs_acessos_controllers]
GO
ALTER TABLE [dbo].[tb_logs_acessos]  WITH CHECK ADD  CONSTRAINT [FK_logs_acessos_usuarios] FOREIGN KEY([usr_cd_usuario])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_logs_acessos] CHECK CONSTRAINT [FK_logs_acessos_usuarios]
GO
ALTER TABLE [dbo].[tb_looker_treinamento_realizado]  WITH CHECK ADD  CONSTRAINT [FK_tb_looker_treinamento_realizado_treinamento] FOREIGN KEY([tnm_cd_treinamento])
REFERENCES [dbo].[tb_looker_treinamento] ([tnm_cd_treinamento])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[tb_looker_treinamento_realizado] CHECK CONSTRAINT [FK_tb_looker_treinamento_realizado_treinamento]
GO
ALTER TABLE [dbo].[tb_map_formulario_usuario]  WITH CHECK ADD  CONSTRAINT [tb_map_form_usuario_tb_formularios_FK] FOREIGN KEY([fru_cd_formulario_usuario])
REFERENCES [dbo].[tb_formularios] ([frm_cd_formulario])
GO
ALTER TABLE [dbo].[tb_map_formulario_usuario] CHECK CONSTRAINT [tb_map_form_usuario_tb_formularios_FK]
GO
ALTER TABLE [dbo].[tb_map_minutas]  WITH CHECK ADD  CONSTRAINT [tb_map_minutas_tb_clientes_FK] FOREIGN KEY([mmi_cd_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_map_minutas] CHECK CONSTRAINT [tb_map_minutas_tb_clientes_FK]
GO
ALTER TABLE [dbo].[tb_map_minutas]  WITH CHECK ADD  CONSTRAINT [tb_map_minutas_tb_usuario_FK] FOREIGN KEY([mmi_cd_motorista])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_map_minutas] CHECK CONSTRAINT [tb_map_minutas_tb_usuario_FK]
GO
ALTER TABLE [dbo].[tb_motorista]  WITH CHECK ADD  CONSTRAINT [fk_motorista_usuario] FOREIGN KEY([mot_cd_usuario])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_motorista] CHECK CONSTRAINT [fk_motorista_usuario]
GO
ALTER TABLE [dbo].[tb_municipios_ibge]  WITH CHECK ADD FOREIGN KEY([estado_ibge])
REFERENCES [dbo].[tb_estados_ibge] ([ibge])
GO
ALTER TABLE [dbo].[tb_notificacoes]  WITH CHECK ADD  CONSTRAINT [fk_notificacao_usr_criacao] FOREIGN KEY([usr_cd_usuario_criacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_notificacoes] CHECK CONSTRAINT [fk_notificacao_usr_criacao]
GO
ALTER TABLE [dbo].[tb_notificacoes]  WITH CHECK ADD  CONSTRAINT [fk_notificacao_usr_modificacao] FOREIGN KEY([usr_cd_usuario_modificacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_notificacoes] CHECK CONSTRAINT [fk_notificacao_usr_modificacao]
GO
ALTER TABLE [dbo].[tb_notification]  WITH CHECK ADD  CONSTRAINT [fk_tb_notification_tb_smartphone_id_usuario] FOREIGN KEY([not_cd_smartphone])
REFERENCES [dbo].[tb_smartphone_id_usuario] ([sid_cd_smartphone_id])
GO
ALTER TABLE [dbo].[tb_notification] CHECK CONSTRAINT [fk_tb_notification_tb_smartphone_id_usuario]
GO
ALTER TABLE [dbo].[tb_ouvidoria]  WITH CHECK ADD  CONSTRAINT [FK__tb_ouvido__IdCli__114C2A18] FOREIGN KEY([IdCliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_ouvidoria] CHECK CONSTRAINT [FK__tb_ouvido__IdCli__114C2A18]
GO
ALTER TABLE [dbo].[tb_ouvidoria]  WITH CHECK ADD  CONSTRAINT [FK__tb_ouvido__IdSet__0E6FBD6D] FOREIGN KEY([IdSetor])
REFERENCES [dbo].[tb_ouvidoria_setores] ([Id])
GO
ALTER TABLE [dbo].[tb_ouvidoria] CHECK CONSTRAINT [FK__tb_ouvido__IdSet__0E6FBD6D]
GO
ALTER TABLE [dbo].[tb_ouvidoria]  WITH CHECK ADD  CONSTRAINT [FK__tb_ouvido__IdSta__105805DF] FOREIGN KEY([IdStatus])
REFERENCES [dbo].[tb_lista] ([lst_cd_lista])
GO
ALTER TABLE [dbo].[tb_ouvidoria] CHECK CONSTRAINT [FK__tb_ouvido__IdSta__105805DF]
GO
ALTER TABLE [dbo].[tb_ouvidoria]  WITH CHECK ADD  CONSTRAINT [FK__tb_ouvido__IdTip__0D7B9934] FOREIGN KEY([IdTipoManifestacao])
REFERENCES [dbo].[tb_lista] ([lst_cd_lista])
GO
ALTER TABLE [dbo].[tb_ouvidoria] CHECK CONSTRAINT [FK__tb_ouvido__IdTip__0D7B9934]
GO
ALTER TABLE [dbo].[tb_ouvidoria]  WITH CHECK ADD  CONSTRAINT [FK__tb_ouvido__IdUsu__0F63E1A6] FOREIGN KEY([IdUsuario])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_ouvidoria] CHECK CONSTRAINT [FK__tb_ouvido__IdUsu__0F63E1A6]
GO
ALTER TABLE [dbo].[tb_ouvidoria]  WITH CHECK ADD  CONSTRAINT [FK_tb_ouvidoria_tb_arquivos] FOREIGN KEY([IdArquivo])
REFERENCES [dbo].[tb_arquivos] ([arq_cd_arquivo])
GO
ALTER TABLE [dbo].[tb_ouvidoria] CHECK CONSTRAINT [FK_tb_ouvidoria_tb_arquivos]
GO
ALTER TABLE [dbo].[tb_ouvidoria]  WITH CHECK ADD  CONSTRAINT [FK_tb_ouvidoria_tb_clientes] FOREIGN KEY([IdCliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_ouvidoria] CHECK CONSTRAINT [FK_tb_ouvidoria_tb_clientes]
GO
ALTER TABLE [dbo].[tb_ouvidoria]  WITH CHECK ADD  CONSTRAINT [FK_tb_ouvidoria_tb_setores] FOREIGN KEY([IdSetor])
REFERENCES [dbo].[tb_ouvidoria_setores] ([Id])
GO
ALTER TABLE [dbo].[tb_ouvidoria] CHECK CONSTRAINT [FK_tb_ouvidoria_tb_setores]
GO
ALTER TABLE [dbo].[tb_ouvidoria]  WITH CHECK ADD  CONSTRAINT [FK_tb_ouvidoria_tb_status] FOREIGN KEY([IdStatus])
REFERENCES [dbo].[tb_lista] ([lst_cd_lista])
GO
ALTER TABLE [dbo].[tb_ouvidoria] CHECK CONSTRAINT [FK_tb_ouvidoria_tb_status]
GO
ALTER TABLE [dbo].[tb_ouvidoria]  WITH CHECK ADD  CONSTRAINT [FK_tb_ouvidoria_tb_tipo_manifestacao] FOREIGN KEY([IdTipoManifestacao])
REFERENCES [dbo].[tb_lista] ([lst_cd_lista])
GO
ALTER TABLE [dbo].[tb_ouvidoria] CHECK CONSTRAINT [FK_tb_ouvidoria_tb_tipo_manifestacao]
GO
ALTER TABLE [dbo].[tb_ouvidoria]  WITH CHECK ADD  CONSTRAINT [FK_tb_ouvidoria_tb_usuario] FOREIGN KEY([IdUsuario])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_ouvidoria] CHECK CONSTRAINT [FK_tb_ouvidoria_tb_usuario]
GO
ALTER TABLE [dbo].[tb_ouvidoria]  WITH CHECK ADD  CONSTRAINT [tb_ouvidoria_tb_arquivos_FK] FOREIGN KEY([IdArquivo])
REFERENCES [dbo].[tb_arquivos] ([arq_cd_arquivo])
GO
ALTER TABLE [dbo].[tb_ouvidoria] CHECK CONSTRAINT [tb_ouvidoria_tb_arquivos_FK]
GO
ALTER TABLE [dbo].[tb_ouvidoria_respostas]  WITH CHECK ADD  CONSTRAINT [FK_OuvidoriaRespostas_Arquivos] FOREIGN KEY([IdArquivo])
REFERENCES [dbo].[tb_arquivos] ([arq_cd_arquivo])
GO
ALTER TABLE [dbo].[tb_ouvidoria_respostas] CHECK CONSTRAINT [FK_OuvidoriaRespostas_Arquivos]
GO
ALTER TABLE [dbo].[tb_ouvidoria_setores]  WITH CHECK ADD FOREIGN KEY([IdCliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_ouvidoria_setores]  WITH CHECK ADD FOREIGN KEY([IdUsuarioCriacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_ouvidoria_setores]  WITH CHECK ADD FOREIGN KEY([IdUsuarioModificacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_ouvidoria_setores_usuarios]  WITH CHECK ADD FOREIGN KEY([IdSetor])
REFERENCES [dbo].[tb_ouvidoria_setores] ([Id])
GO
ALTER TABLE [dbo].[tb_ouvidoria_setores_usuarios]  WITH CHECK ADD FOREIGN KEY([IdUsuario])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_pac_sinistros]  WITH CHECK ADD  CONSTRAINT [fk_tb_pac_sinistros_tb_usuario_alteracao] FOREIGN KEY([pac_cd_usr_modificacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_pac_sinistros] CHECK CONSTRAINT [fk_tb_pac_sinistros_tb_usuario_alteracao]
GO
ALTER TABLE [dbo].[tb_pac_sinistros]  WITH CHECK ADD  CONSTRAINT [fk_tb_pac_sinistros_tb_usuario_criacao] FOREIGN KEY([pac_cd_usr_criacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_pac_sinistros] CHECK CONSTRAINT [fk_tb_pac_sinistros_tb_usuario_criacao]
GO
ALTER TABLE [dbo].[tb_pac_sinistros]  WITH CHECK ADD  CONSTRAINT [fk_tb_pac_sinitros_tb_sin_sinistro] FOREIGN KEY([pac_cd_sin_sinistro])
REFERENCES [dbo].[tb_sin_sinistro] ([sin_cd_sinistro])
GO
ALTER TABLE [dbo].[tb_pac_sinistros] CHECK CONSTRAINT [fk_tb_pac_sinitros_tb_sin_sinistro]
GO
ALTER TABLE [dbo].[tb_pag_espelhos]  WITH CHECK ADD  CONSTRAINT [fk_tb_motorista_nfs_tb_cod_cliente] FOREIGN KEY([mtn_cod_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_pag_espelhos] CHECK CONSTRAINT [fk_tb_motorista_nfs_tb_cod_cliente]
GO
ALTER TABLE [dbo].[tb_pag_espelhos]  WITH CHECK ADD  CONSTRAINT [fk_tb_motorista_nfs_tb_tb_lista] FOREIGN KEY([mtn_cd_status])
REFERENCES [dbo].[tb_lista] ([lst_cd_lista])
GO
ALTER TABLE [dbo].[tb_pag_espelhos] CHECK CONSTRAINT [fk_tb_motorista_nfs_tb_tb_lista]
GO
ALTER TABLE [dbo].[tb_pag_espelhos]  WITH CHECK ADD  CONSTRAINT [fk_tb_motorista_nfs_tb_tb_pgto_periodo] FOREIGN KEY([mtn_cd_pgto_periodo])
REFERENCES [dbo].[tb_pgto_periodo] ([pgp_cd_periodo])
GO
ALTER TABLE [dbo].[tb_pag_espelhos] CHECK CONSTRAINT [fk_tb_motorista_nfs_tb_tb_pgto_periodo]
GO
ALTER TABLE [dbo].[tb_pag_espelhos]  WITH CHECK ADD  CONSTRAINT [fk_tb_motorista_nfs_tb_usuario_alteracao] FOREIGN KEY([mtn_cd_usr_modificacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_pag_espelhos] CHECK CONSTRAINT [fk_tb_motorista_nfs_tb_usuario_alteracao]
GO
ALTER TABLE [dbo].[tb_pag_espelhos]  WITH CHECK ADD  CONSTRAINT [fk_tb_motorista_nfs_tb_usuario_criacao] FOREIGN KEY([mtn_cd_usr_criacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_pag_espelhos] CHECK CONSTRAINT [fk_tb_motorista_nfs_tb_usuario_criacao]
GO
ALTER TABLE [dbo].[tb_pag_espelhos]  WITH CHECK ADD  CONSTRAINT [fk_tb_motorista_nfs_tb_usuario_motorista] FOREIGN KEY([mtn_cd_motorista])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_pag_espelhos] CHECK CONSTRAINT [fk_tb_motorista_nfs_tb_usuario_motorista]
GO
ALTER TABLE [dbo].[tb_pag_espelhos]  WITH CHECK ADD  CONSTRAINT [FK_tb_pag_espelhos_tb_lista] FOREIGN KEY([mtn_cd_cliente_transportadora])
REFERENCES [dbo].[tb_lista] ([lst_cd_lista])
GO
ALTER TABLE [dbo].[tb_pag_espelhos] CHECK CONSTRAINT [FK_tb_pag_espelhos_tb_lista]
GO
ALTER TABLE [dbo].[tb_pag_espelhos]  WITH CHECK ADD  CONSTRAINT [FK_tb_pag_espelhos_tb_lista1] FOREIGN KEY([mtn_cd_tipo_espelho])
REFERENCES [dbo].[tb_lista] ([lst_cd_lista])
GO
ALTER TABLE [dbo].[tb_pag_espelhos] CHECK CONSTRAINT [FK_tb_pag_espelhos_tb_lista1]
GO
ALTER TABLE [dbo].[tb_pag_espelhos_logs]  WITH CHECK ADD  CONSTRAINT [fk_log_status_motorista_nfs_tb_lista_status_anterior] FOREIGN KEY([lsm_cd_status_anterior])
REFERENCES [dbo].[tb_lista] ([lst_cd_lista])
GO
ALTER TABLE [dbo].[tb_pag_espelhos_logs] CHECK CONSTRAINT [fk_log_status_motorista_nfs_tb_lista_status_anterior]
GO
ALTER TABLE [dbo].[tb_pag_espelhos_logs]  WITH CHECK ADD  CONSTRAINT [fk_log_status_motorista_nfs_tb_lista_status_atual] FOREIGN KEY([lsm_cd_status_atual])
REFERENCES [dbo].[tb_lista] ([lst_cd_lista])
GO
ALTER TABLE [dbo].[tb_pag_espelhos_logs] CHECK CONSTRAINT [fk_log_status_motorista_nfs_tb_lista_status_atual]
GO
ALTER TABLE [dbo].[tb_pag_espelhos_logs]  WITH CHECK ADD  CONSTRAINT [fk_log_status_motorista_nfs_tb_usuario] FOREIGN KEY([lsm_cd_usuario])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_pag_espelhos_logs] CHECK CONSTRAINT [fk_log_status_motorista_nfs_tb_usuario]
GO
ALTER TABLE [dbo].[tb_pag_espelhos_nfse]  WITH CHECK ADD  CONSTRAINT [FK_tb_pag_espelhos_nfse_status_integracao] FOREIGN KEY([enf_status_integracao])
REFERENCES [dbo].[tb_lista] ([lst_cd_lista])
GO
ALTER TABLE [dbo].[tb_pag_espelhos_nfse] CHECK CONSTRAINT [FK_tb_pag_espelhos_nfse_status_integracao]
GO
ALTER TABLE [dbo].[tb_pag_integracao_bancos]  WITH CHECK ADD  CONSTRAINT [fk_pag_integracao_bancos_cliente] FOREIGN KEY([pib_cd_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_pag_integracao_bancos] CHECK CONSTRAINT [fk_pag_integracao_bancos_cliente]
GO
ALTER TABLE [dbo].[tb_pag_integracao_bancos]  WITH CHECK ADD  CONSTRAINT [fk_pag_integracao_bancos_espelho] FOREIGN KEY([pib_cd_espelho])
REFERENCES [dbo].[tb_pag_espelhos] ([mtn_cd_motorista_nfs])
GO
ALTER TABLE [dbo].[tb_pag_integracao_bancos] CHECK CONSTRAINT [fk_pag_integracao_bancos_espelho]
GO
ALTER TABLE [dbo].[tb_pag_integracao_bancos]  WITH CHECK ADD  CONSTRAINT [fk_pag_integracao_bancos_status_irisys] FOREIGN KEY([pib_cd_status_irisys])
REFERENCES [dbo].[tb_lista] ([lst_cd_lista])
GO
ALTER TABLE [dbo].[tb_pag_integracao_bancos] CHECK CONSTRAINT [fk_pag_integracao_bancos_status_irisys]
GO
ALTER TABLE [dbo].[tb_pag_integracao_bancos]  WITH CHECK ADD  CONSTRAINT [fk_pag_integracao_bancos_status_terceiro] FOREIGN KEY([pib_cd_status_terceiro])
REFERENCES [dbo].[tb_lista] ([lst_cd_lista])
GO
ALTER TABLE [dbo].[tb_pag_integracao_bancos] CHECK CONSTRAINT [fk_pag_integracao_bancos_status_terceiro]
GO
ALTER TABLE [dbo].[tb_pag_integracao_bancos]  WITH CHECK ADD  CONSTRAINT [fk_pag_integracao_bancos_tipo] FOREIGN KEY([pib_ds_tipo_integracao])
REFERENCES [dbo].[tb_lista] ([lst_cd_lista])
GO
ALTER TABLE [dbo].[tb_pag_integracao_bancos] CHECK CONSTRAINT [fk_pag_integracao_bancos_tipo]
GO
ALTER TABLE [dbo].[tb_pag_integracao_bancos]  WITH CHECK ADD  CONSTRAINT [fk_pag_integracao_bancos_transf] FOREIGN KEY([pib_cd_tipo_transferencia])
REFERENCES [dbo].[tb_lista] ([lst_cd_lista])
GO
ALTER TABLE [dbo].[tb_pag_integracao_bancos] CHECK CONSTRAINT [fk_pag_integracao_bancos_transf]
GO
ALTER TABLE [dbo].[tb_parametros]  WITH CHECK ADD  CONSTRAINT [fk_prm_cli_cod_cliente] FOREIGN KEY([prm_cod_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_parametros] CHECK CONSTRAINT [fk_prm_cli_cod_cliente]
GO
ALTER TABLE [dbo].[tb_parametros]  WITH CHECK ADD  CONSTRAINT [fk_prm_usr_criacao] FOREIGN KEY([prm_cd_usuario_criacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_parametros] CHECK CONSTRAINT [fk_prm_usr_criacao]
GO
ALTER TABLE [dbo].[tb_parametros]  WITH CHECK ADD  CONSTRAINT [fk_prm_usr_modificacao] FOREIGN KEY([prm_cd_usuario_modificacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_parametros] CHECK CONSTRAINT [fk_prm_usr_modificacao]
GO
ALTER TABLE [dbo].[tb_pbi_mon_alertas_fato]  WITH CHECK ADD  CONSTRAINT [FK_tb_pbi_mon_alertas_fato_cliente] FOREIGN KEY([cli_cd_codigo_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_pbi_mon_alertas_fato] CHECK CONSTRAINT [FK_tb_pbi_mon_alertas_fato_cliente]
GO
ALTER TABLE [dbo].[tb_pbi_mon_alertas_fato]  WITH CHECK ADD  CONSTRAINT [FK_tb_pbi_mon_alertas_fato_processo] FOREIGN KEY([processo_id])
REFERENCES [dbo].[tb_pbi_mon_processo] ([processo_id])
GO
ALTER TABLE [dbo].[tb_pbi_mon_alertas_fato] CHECK CONSTRAINT [FK_tb_pbi_mon_alertas_fato_processo]
GO
ALTER TABLE [dbo].[tb_pbi_mon_etapas]  WITH CHECK ADD  CONSTRAINT [fk_pbi_mon_etapas_fluxo] FOREIGN KEY([fluxo_id])
REFERENCES [dbo].[tb_pbi_mon_fluxos] ([fluxo_id])
GO
ALTER TABLE [dbo].[tb_pbi_mon_etapas] CHECK CONSTRAINT [fk_pbi_mon_etapas_fluxo]
GO
ALTER TABLE [dbo].[tb_pbi_mon_fluxos]  WITH CHECK ADD  CONSTRAINT [fk_pbi_mon_fluxos_processo] FOREIGN KEY([processo_id])
REFERENCES [dbo].[tb_pbi_mon_processo] ([processo_id])
GO
ALTER TABLE [dbo].[tb_pbi_mon_fluxos] CHECK CONSTRAINT [fk_pbi_mon_fluxos_processo]
GO
ALTER TABLE [dbo].[tb_pbi_mon_log_alertas]  WITH CHECK ADD  CONSTRAINT [FK_tb_pbi_mon_log_alertas_processo] FOREIGN KEY([processo_id])
REFERENCES [dbo].[tb_pbi_mon_processo] ([processo_id])
GO
ALTER TABLE [dbo].[tb_pbi_mon_log_alertas] CHECK CONSTRAINT [FK_tb_pbi_mon_log_alertas_processo]
GO
ALTER TABLE [dbo].[tb_pbi_mon_processo_acao_log]  WITH CHECK ADD  CONSTRAINT [FK_tb_pbi_mon_processo_acao_log_processo] FOREIGN KEY([processo_id])
REFERENCES [dbo].[tb_pbi_mon_processo] ([processo_id])
GO
ALTER TABLE [dbo].[tb_pbi_mon_processo_acao_log] CHECK CONSTRAINT [FK_tb_pbi_mon_processo_acao_log_processo]
GO
ALTER TABLE [dbo].[tb_pgto_espelho_importacoes]  WITH CHECK ADD  CONSTRAINT [fk_pgto_espelho_import_cliente] FOREIGN KEY([pei_cd_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_pgto_espelho_importacoes] CHECK CONSTRAINT [fk_pgto_espelho_import_cliente]
GO
ALTER TABLE [dbo].[tb_pgto_espelho_importacoes]  WITH CHECK ADD  CONSTRAINT [fk_pgto_espelho_import_periodo] FOREIGN KEY([pei_cd_periodo])
REFERENCES [dbo].[tb_pgto_periodo] ([pgp_cd_periodo])
GO
ALTER TABLE [dbo].[tb_pgto_espelho_importacoes] CHECK CONSTRAINT [fk_pgto_espelho_import_periodo]
GO
ALTER TABLE [dbo].[tb_pgto_espelho_importacoes]  WITH CHECK ADD  CONSTRAINT [fk_pgto_espelho_import_tipo_espelho] FOREIGN KEY([pei_cd_tipo_espelho])
REFERENCES [dbo].[tb_lista] ([lst_cd_lista])
GO
ALTER TABLE [dbo].[tb_pgto_espelho_importacoes] CHECK CONSTRAINT [fk_pgto_espelho_import_tipo_espelho]
GO
ALTER TABLE [dbo].[tb_pgto_espelho_importacoes]  WITH CHECK ADD  CONSTRAINT [fk_pgto_espelho_import_usr_criacao] FOREIGN KEY([pei_cd_usr_criacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_pgto_espelho_importacoes] CHECK CONSTRAINT [fk_pgto_espelho_import_usr_criacao]
GO
ALTER TABLE [dbo].[tb_pgto_espelho_importacoes_detalhes]  WITH CHECK ADD  CONSTRAINT [fk_pgto_espelho_import_det_importacao] FOREIGN KEY([peid_cd_importacao])
REFERENCES [dbo].[tb_pgto_espelho_importacoes] ([pei_cd_importacao])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_pgto_espelho_importacoes_detalhes] CHECK CONSTRAINT [fk_pgto_espelho_import_det_importacao]
GO
ALTER TABLE [dbo].[tb_pgto_periodo]  WITH CHECK ADD  CONSTRAINT [fk_tb_pgto_periodo_tb_cliente] FOREIGN KEY([pgp_cd_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_pgto_periodo] CHECK CONSTRAINT [fk_tb_pgto_periodo_tb_cliente]
GO
ALTER TABLE [dbo].[tb_pgto_periodo]  WITH CHECK ADD  CONSTRAINT [fk_tb_pgto_periodo_tb_usuario_alteracao] FOREIGN KEY([pgp_cd_usr_modificacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_pgto_periodo] CHECK CONSTRAINT [fk_tb_pgto_periodo_tb_usuario_alteracao]
GO
ALTER TABLE [dbo].[tb_pgto_periodo]  WITH CHECK ADD  CONSTRAINT [fk_tb_pgto_periodo_tb_usuario_criacao] FOREIGN KEY([pgp_cd_usr_criacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_pgto_periodo] CHECK CONSTRAINT [fk_tb_pgto_periodo_tb_usuario_criacao]
GO
ALTER TABLE [dbo].[tb_pgto_periodo_rota]  WITH CHECK ADD  CONSTRAINT [fk_pgto_periodo_rota_cd_periodo] FOREIGN KEY([ppr_cd_periodo])
REFERENCES [dbo].[tb_pgto_periodo] ([pgp_cd_periodo])
GO
ALTER TABLE [dbo].[tb_pgto_periodo_rota] CHECK CONSTRAINT [fk_pgto_periodo_rota_cd_periodo]
GO
ALTER TABLE [dbo].[tb_pgto_periodo_rota]  WITH CHECK ADD  CONSTRAINT [fk_pgto_periodo_rota_nfs] FOREIGN KEY([ppr_cd_motorista_nfs])
REFERENCES [dbo].[tb_pag_espelhos] ([mtn_cd_motorista_nfs])
GO
ALTER TABLE [dbo].[tb_pgto_periodo_rota] CHECK CONSTRAINT [fk_pgto_periodo_rota_nfs]
GO
ALTER TABLE [dbo].[tb_pgto_periodo_rota]  WITH NOCHECK ADD  CONSTRAINT [fk_pgto_periodo_rota_usuario] FOREIGN KEY([ppr_cd_motorista])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_pgto_periodo_rota] CHECK CONSTRAINT [fk_pgto_periodo_rota_usuario]
GO
ALTER TABLE [dbo].[tb_pgto_periodo_rota]  WITH CHECK ADD  CONSTRAINT [fk_tb_pgto_periodo_rota_tb_usuario_alteracao] FOREIGN KEY([ppr_cd_usr_modificacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_pgto_periodo_rota] CHECK CONSTRAINT [fk_tb_pgto_periodo_rota_tb_usuario_alteracao]
GO
ALTER TABLE [dbo].[tb_pgto_periodo_rota]  WITH CHECK ADD  CONSTRAINT [fk_tb_pgto_periodo_rota_tb_usuario_criacao] FOREIGN KEY([ppr_cd_usr_criacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_pgto_periodo_rota] CHECK CONSTRAINT [fk_tb_pgto_periodo_rota_tb_usuario_criacao]
GO
ALTER TABLE [dbo].[tb_push_notification_fila]  WITH CHECK ADD  CONSTRAINT [FK_tb_push_notification_fila_cliente] FOREIGN KEY([pnf_cd_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_push_notification_fila] CHECK CONSTRAINT [FK_tb_push_notification_fila_cliente]
GO
ALTER TABLE [dbo].[tb_push_notification_fila]  WITH CHECK ADD  CONSTRAINT [FK_tb_push_notification_fila_usuario] FOREIGN KEY([pnf_cd_usuario])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_push_notification_fila] CHECK CONSTRAINT [FK_tb_push_notification_fila_usuario]
GO
ALTER TABLE [dbo].[tb_rcto_periodo]  WITH CHECK ADD  CONSTRAINT [fk_tb_rcto_periodo_tb_cliente] FOREIGN KEY([rcb_cd_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_rcto_periodo] CHECK CONSTRAINT [fk_tb_rcto_periodo_tb_cliente]
GO
ALTER TABLE [dbo].[tb_rcto_periodo]  WITH CHECK ADD  CONSTRAINT [fk_tb_rcto_periodo_tb_usuario_alteracao] FOREIGN KEY([rcb_cd_usr_modificacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_rcto_periodo] CHECK CONSTRAINT [fk_tb_rcto_periodo_tb_usuario_alteracao]
GO
ALTER TABLE [dbo].[tb_rcto_periodo]  WITH CHECK ADD  CONSTRAINT [fk_tb_rcto_periodo_tb_usuario_criacao] FOREIGN KEY([rcb_cd_usr_criacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_rcto_periodo] CHECK CONSTRAINT [fk_tb_rcto_periodo_tb_usuario_criacao]
GO
ALTER TABLE [dbo].[tb_rcto_periodo]  WITH CHECK ADD  CONSTRAINT [fk_tb_tb_rcto_periodo_tb_cliente] FOREIGN KEY([rcb_cd_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_rcto_periodo] CHECK CONSTRAINT [fk_tb_tb_rcto_periodo_tb_cliente]
GO
ALTER TABLE [dbo].[tb_rcto_periodo_rota]  WITH CHECK ADD  CONSTRAINT [fk_tb_rcto_periodo_rota_tb_rcp_cd_periodo] FOREIGN KEY([rcp_cd_periodo])
REFERENCES [dbo].[tb_rcto_periodo] ([rcb_cd_periodo])
GO
ALTER TABLE [dbo].[tb_rcto_periodo_rota] CHECK CONSTRAINT [fk_tb_rcto_periodo_rota_tb_rcp_cd_periodo]
GO
ALTER TABLE [dbo].[tb_rcto_periodo_rota]  WITH CHECK ADD  CONSTRAINT [fk_tb_rcto_periodo_rota_tb_usuario_alteracao] FOREIGN KEY([rcp_cd_usr_modificacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_rcto_periodo_rota] CHECK CONSTRAINT [fk_tb_rcto_periodo_rota_tb_usuario_alteracao]
GO
ALTER TABLE [dbo].[tb_rcto_periodo_rota]  WITH CHECK ADD  CONSTRAINT [fk_tb_rcto_periodo_rota_tb_usuario_criacao] FOREIGN KEY([rcp_cd_usr_criacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_rcto_periodo_rota] CHECK CONSTRAINT [fk_tb_rcto_periodo_rota_tb_usuario_criacao]
GO
ALTER TABLE [dbo].[tb_refresh_token]  WITH CHECK ADD  CONSTRAINT [FK_refresh_token_cd_usuarios] FOREIGN KEY([rft_cd_usuario])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_refresh_token] CHECK CONSTRAINT [FK_refresh_token_cd_usuarios]
GO
ALTER TABLE [dbo].[tb_registro_gps]  WITH CHECK ADD  CONSTRAINT [fk_registro_gps_rgp_cd_usuario] FOREIGN KEY([rgp_cd_usuario])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_registro_gps] CHECK CONSTRAINT [fk_registro_gps_rgp_cd_usuario]
GO
ALTER TABLE [dbo].[tb_relatorio_logs]  WITH CHECK ADD  CONSTRAINT [FK_tb_relatorio_log_relatorio] FOREIGN KEY([rel_cd_relatorio])
REFERENCES [dbo].[tb_relatorios] ([rel_cd_relatorio])
GO
ALTER TABLE [dbo].[tb_relatorio_logs] CHECK CONSTRAINT [FK_tb_relatorio_log_relatorio]
GO
ALTER TABLE [dbo].[tb_relatorio_logs]  WITH CHECK ADD  CONSTRAINT [FK_tb_relatorio_log_usuario] FOREIGN KEY([rel_cd_usuario])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_relatorio_logs] CHECK CONSTRAINT [FK_tb_relatorio_log_usuario]
GO
ALTER TABLE [dbo].[tb_relatorios]  WITH CHECK ADD  CONSTRAINT [fk_tb_relatorios_controller] FOREIGN KEY([rel_cd_controller])
REFERENCES [dbo].[tb_controller] ([ctr_cd_controller])
GO
ALTER TABLE [dbo].[tb_relatorios] CHECK CONSTRAINT [fk_tb_relatorios_controller]
GO
ALTER TABLE [dbo].[tb_relatorios]  WITH CHECK ADD  CONSTRAINT [fk_tb_relatorios_usr_criacao] FOREIGN KEY([rel_cd_usr_criacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_relatorios] CHECK CONSTRAINT [fk_tb_relatorios_usr_criacao]
GO
ALTER TABLE [dbo].[tb_relatorios]  WITH CHECK ADD  CONSTRAINT [fk_tb_relatorios_usr_modificacao] FOREIGN KEY([rel_cd_usr_modificacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_relatorios] CHECK CONSTRAINT [fk_tb_relatorios_usr_modificacao]
GO
ALTER TABLE [dbo].[tb_relatorios_filtros]  WITH CHECK ADD  CONSTRAINT [fk_relatorios_filtros_cod_relatorio] FOREIGN KEY([rfl_cd_rel_relatorio])
REFERENCES [dbo].[tb_relatorios] ([rel_cd_relatorio])
GO
ALTER TABLE [dbo].[tb_relatorios_filtros] CHECK CONSTRAINT [fk_relatorios_filtros_cod_relatorio]
GO
ALTER TABLE [dbo].[tb_relatorios_filtros_usuarios]  WITH CHECK ADD  CONSTRAINT [fk_rfl_rfu_cd_filtro] FOREIGN KEY([rfu_cd_relatorios_filtro])
REFERENCES [dbo].[tb_relatorios_filtros] ([rfl_cd_filtro])
GO
ALTER TABLE [dbo].[tb_relatorios_filtros_usuarios] CHECK CONSTRAINT [fk_rfl_rfu_cd_filtro]
GO
ALTER TABLE [dbo].[tb_relatorios_filtros_usuarios]  WITH CHECK ADD  CONSTRAINT [fk_usr_rfu_cd_usuario] FOREIGN KEY([rfu_cd_usuario])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_relatorios_filtros_usuarios] CHECK CONSTRAINT [fk_usr_rfu_cd_usuario]
GO
ALTER TABLE [dbo].[tb_rotas_dados_transportadora]  WITH CHECK ADD  CONSTRAINT [fk_tb_rotas_dados_transportadora_tb_cliente] FOREIGN KEY([rdt_cd_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_rotas_dados_transportadora] CHECK CONSTRAINT [fk_tb_rotas_dados_transportadora_tb_cliente]
GO
ALTER TABLE [dbo].[tb_rotas_dados_transportadora]  WITH CHECK ADD  CONSTRAINT [fk_tb_rotas_dados_transportadora_tb_usuario_alteracao] FOREIGN KEY([rdt_cd_usr_modificacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_rotas_dados_transportadora] CHECK CONSTRAINT [fk_tb_rotas_dados_transportadora_tb_usuario_alteracao]
GO
ALTER TABLE [dbo].[tb_rotas_dados_transportadora]  WITH CHECK ADD  CONSTRAINT [fk_tb_rotas_dados_transportadora_tb_usuario_criacao] FOREIGN KEY([rdt_cd_usr_criacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_rotas_dados_transportadora] CHECK CONSTRAINT [fk_tb_rotas_dados_transportadora_tb_usuario_criacao]
GO
ALTER TABLE [dbo].[tb_rotinas]  WITH CHECK ADD  CONSTRAINT [FK_tb_rotinas_tb_rotina_tipo] FOREIGN KEY([rtn_cd_rotina_tipo])
REFERENCES [dbo].[tb_rotina_tipo] ([rtt_cd_rotina_tipo])
GO
ALTER TABLE [dbo].[tb_rotinas] CHECK CONSTRAINT [FK_tb_rotinas_tb_rotina_tipo]
GO
ALTER TABLE [dbo].[tb_rotinas]  WITH CHECK ADD  CONSTRAINT [FK_tb_rotinas_tb_usuario] FOREIGN KEY([rtn_cd_usr_criacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_rotinas] CHECK CONSTRAINT [FK_tb_rotinas_tb_usuario]
GO
ALTER TABLE [dbo].[tb_rotinas]  WITH CHECK ADD  CONSTRAINT [FK_tb_rotinas_tb_usuario1] FOREIGN KEY([rtn_cd_usr_modificacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_rotinas] CHECK CONSTRAINT [FK_tb_rotinas_tb_usuario1]
GO
ALTER TABLE [dbo].[tb_sessao_usuario]  WITH CHECK ADD  CONSTRAINT [FK_sessao_usuario_usuario] FOREIGN KEY([usr_cd_usuario])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_sessao_usuario] CHECK CONSTRAINT [FK_sessao_usuario_usuario]
GO
ALTER TABLE [dbo].[tb_setor]  WITH CHECK ADD  CONSTRAINT [fk_tb_setor_tb_clientes] FOREIGN KEY([set_cd_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_setor] CHECK CONSTRAINT [fk_tb_setor_tb_clientes]
GO
ALTER TABLE [dbo].[tb_setor]  WITH CHECK ADD  CONSTRAINT [fk_tb_setor_tb_usuario_criacao] FOREIGN KEY([set_cd_usuario_criacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_setor] CHECK CONSTRAINT [fk_tb_setor_tb_usuario_criacao]
GO
ALTER TABLE [dbo].[tb_setor]  WITH CHECK ADD  CONSTRAINT [fk_tb_setor_tb_usuario_modificacao] FOREIGN KEY([set_cd_usuario_modificacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_setor] CHECK CONSTRAINT [fk_tb_setor_tb_usuario_modificacao]
GO
ALTER TABLE [dbo].[tb_setor_grupo_acesso]  WITH CHECK ADD  CONSTRAINT [fk_tb_setor_grupo_acesso_tb_clientes] FOREIGN KEY([sga_cd_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_setor_grupo_acesso] CHECK CONSTRAINT [fk_tb_setor_grupo_acesso_tb_clientes]
GO
ALTER TABLE [dbo].[tb_setor_grupo_acesso]  WITH CHECK ADD  CONSTRAINT [fk_tb_setor_grupo_acesso_tb_grupo_acesso] FOREIGN KEY([sga_cd_grupo_acesso])
REFERENCES [dbo].[tb_grupo_acesso] ([gpa_cd_grupo_acesso])
GO
ALTER TABLE [dbo].[tb_setor_grupo_acesso] CHECK CONSTRAINT [fk_tb_setor_grupo_acesso_tb_grupo_acesso]
GO
ALTER TABLE [dbo].[tb_setor_grupo_acesso]  WITH CHECK ADD  CONSTRAINT [fk_tb_setor_grupo_acesso_tb_setor] FOREIGN KEY([sga_cd_setor])
REFERENCES [dbo].[tb_setor] ([set_cd_setor])
GO
ALTER TABLE [dbo].[tb_setor_grupo_acesso] CHECK CONSTRAINT [fk_tb_setor_grupo_acesso_tb_setor]
GO
ALTER TABLE [dbo].[tb_sin_sinistro]  WITH CHECK ADD  CONSTRAINT [fk_tb_sin_sinistro_tb_usuario_alteracao] FOREIGN KEY([sin_cd_usr_modificacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_sin_sinistro] CHECK CONSTRAINT [fk_tb_sin_sinistro_tb_usuario_alteracao]
GO
ALTER TABLE [dbo].[tb_sin_sinistro]  WITH CHECK ADD  CONSTRAINT [fk_tb_sin_sinistro_tb_usuario_criacao] FOREIGN KEY([sin_cd_usr_criacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_sin_sinistro] CHECK CONSTRAINT [fk_tb_sin_sinistro_tb_usuario_criacao]
GO
ALTER TABLE [dbo].[tb_sin_sinistro]  WITH CHECK ADD  CONSTRAINT [fk_tb_sin_sinitro_tb_cliente] FOREIGN KEY([sin_cd_cliente_transportadora])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_sin_sinistro] CHECK CONSTRAINT [fk_tb_sin_sinitro_tb_cliente]
GO
ALTER TABLE [dbo].[tb_smartphone_id_usuario]  WITH CHECK ADD  CONSTRAINT [fk_tb_smartphone_id_usuario] FOREIGN KEY([sid_cd_usuario])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_smartphone_id_usuario] CHECK CONSTRAINT [fk_tb_smartphone_id_usuario]
GO
ALTER TABLE [dbo].[tb_termos_aceites]  WITH CHECK ADD  CONSTRAINT [fk_termo_aceite_cod_cliente] FOREIGN KEY([tra_cd_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_termos_aceites] CHECK CONSTRAINT [fk_termo_aceite_cod_cliente]
GO
ALTER TABLE [dbo].[tb_termos_aceites]  WITH CHECK ADD  CONSTRAINT [fk_termo_aceite_usuario_criacao] FOREIGN KEY([tra_cd_usuario_criacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_termos_aceites] CHECK CONSTRAINT [fk_termo_aceite_usuario_criacao]
GO
ALTER TABLE [dbo].[tb_termos_aceites]  WITH CHECK ADD  CONSTRAINT [fk_termo_aceite_usuario_modificacao] FOREIGN KEY([tra_cd_usuario_modificacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_termos_aceites] CHECK CONSTRAINT [fk_termo_aceite_usuario_modificacao]
GO
ALTER TABLE [dbo].[tb_termos_aceites_confirmados]  WITH CHECK ADD  CONSTRAINT [fk_termo_aceite_confirmado_cd_termo_aceite] FOREIGN KEY([tac_cd_termo_aceite])
REFERENCES [dbo].[tb_termos_aceites] ([tra_cd_termo_aceite])
GO
ALTER TABLE [dbo].[tb_termos_aceites_confirmados] CHECK CONSTRAINT [fk_termo_aceite_confirmado_cd_termo_aceite]
GO
ALTER TABLE [dbo].[tb_termos_aceites_confirmados]  WITH CHECK ADD  CONSTRAINT [fk_termo_aceite_confirmado_cod_cliente] FOREIGN KEY([tac_cd_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_termos_aceites_confirmados] CHECK CONSTRAINT [fk_termo_aceite_confirmado_cod_cliente]
GO
ALTER TABLE [dbo].[tb_termos_aceites_confirmados]  WITH CHECK ADD  CONSTRAINT [fk_termo_aceite_confirmado_usuario] FOREIGN KEY([tac_cd_usuario])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_termos_aceites_confirmados] CHECK CONSTRAINT [fk_termo_aceite_confirmado_usuario]
GO
ALTER TABLE [dbo].[tb_termos_aceites_confirmados]  WITH CHECK ADD  CONSTRAINT [fk_termo_aceite_confirmado_usuario_criacao] FOREIGN KEY([tac_cd_usuario_criacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_termos_aceites_confirmados] CHECK CONSTRAINT [fk_termo_aceite_confirmado_usuario_criacao]
GO
ALTER TABLE [dbo].[tb_termos_aceites_confirmados]  WITH CHECK ADD  CONSTRAINT [fk_termo_aceite_confirmado_usuario_modificacao] FOREIGN KEY([tac_cd_usuario_modificacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_termos_aceites_confirmados] CHECK CONSTRAINT [fk_termo_aceite_confirmado_usuario_modificacao]
GO
ALTER TABLE [dbo].[tb_termos_aceites_tipo_contrato]  WITH CHECK ADD  CONSTRAINT [fk_termos_aceites_tipo_contrato_termos_aceites] FOREIGN KEY([tat_cd_termos_aceite])
REFERENCES [dbo].[tb_termos_aceites] ([tra_cd_termo_aceite])
GO
ALTER TABLE [dbo].[tb_termos_aceites_tipo_contrato] CHECK CONSTRAINT [fk_termos_aceites_tipo_contrato_termos_aceites]
GO
ALTER TABLE [dbo].[tb_termos_aceites_tipo_contrato]  WITH CHECK ADD  CONSTRAINT [fk_termos_aceites_tipo_contrato_tipo_contrato] FOREIGN KEY([tat_cd_tipo_contrato])
REFERENCES [dbo].[tb_tipo_contrato] ([ttc_cd_tipo_contrato])
GO
ALTER TABLE [dbo].[tb_termos_aceites_tipo_contrato] CHECK CONSTRAINT [fk_termos_aceites_tipo_contrato_tipo_contrato]
GO
ALTER TABLE [dbo].[tb_tipo_contrato]  WITH CHECK ADD  CONSTRAINT [FK_tb_tipo_contrato_tb_formularios] FOREIGN KEY([ttc_cd_formulario])
REFERENCES [dbo].[tb_formularios] ([frm_cd_formulario])
GO
ALTER TABLE [dbo].[tb_tipo_contrato] CHECK CONSTRAINT [FK_tb_tipo_contrato_tb_formularios]
GO
ALTER TABLE [dbo].[tb_tipo_contrato]  WITH CHECK ADD  CONSTRAINT [fk_tipo_contrato_cliente] FOREIGN KEY([ttc_cd_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_tipo_contrato] CHECK CONSTRAINT [fk_tipo_contrato_cliente]
GO
ALTER TABLE [dbo].[tb_tipo_contrato]  WITH CHECK ADD  CONSTRAINT [fk_tipo_contrato_usuario_criacao] FOREIGN KEY([ttc_cd_usuario_criacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_tipo_contrato] CHECK CONSTRAINT [fk_tipo_contrato_usuario_criacao]
GO
ALTER TABLE [dbo].[tb_tipo_contrato]  WITH CHECK ADD  CONSTRAINT [fk_tipo_contrato_usuario_modificacao] FOREIGN KEY([ttc_cd_usuario_modificacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_tipo_contrato] CHECK CONSTRAINT [fk_tipo_contrato_usuario_modificacao]
GO
ALTER TABLE [dbo].[tb_tipos_lancamentos_grupos_acesso]  WITH CHECK ADD  CONSTRAINT [fk_tipos_lancamentos_grupos_acesso_grupo_acesso] FOREIGN KEY([lga_cd_grupo_acesso])
REFERENCES [dbo].[tb_grupo_acesso] ([gpa_cd_grupo_acesso])
GO
ALTER TABLE [dbo].[tb_tipos_lancamentos_grupos_acesso] CHECK CONSTRAINT [fk_tipos_lancamentos_grupos_acesso_grupo_acesso]
GO
ALTER TABLE [dbo].[tb_tipos_lancamentos_grupos_acesso]  WITH CHECK ADD  CONSTRAINT [fk_tipos_lancamentos_grupos_acesso_tipo_lancamento_manual] FOREIGN KEY([lga_cd_tipo_lancamento_manual])
REFERENCES [dbo].[tb_tipos_lancamentos_manuais] ([plm_cd_tipo_lancamento_manual])
GO
ALTER TABLE [dbo].[tb_tipos_lancamentos_grupos_acesso] CHECK CONSTRAINT [fk_tipos_lancamentos_grupos_acesso_tipo_lancamento_manual]
GO
ALTER TABLE [dbo].[tb_tipos_lancamentos_manuais]  WITH CHECK ADD  CONSTRAINT [fk_tb_tipos_lancamentos_manuais_tb_clientes] FOREIGN KEY([plm_cd_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_tipos_lancamentos_manuais] CHECK CONSTRAINT [fk_tb_tipos_lancamentos_manuais_tb_clientes]
GO
ALTER TABLE [dbo].[tb_tipos_lancamentos_manuais]  WITH CHECK ADD  CONSTRAINT [fk_tb_tipos_lancamentos_manuais_tb_lista] FOREIGN KEY([plm_cd_cliente_transportadora])
REFERENCES [dbo].[tb_lista] ([lst_cd_lista])
GO
ALTER TABLE [dbo].[tb_tipos_lancamentos_manuais] CHECK CONSTRAINT [fk_tb_tipos_lancamentos_manuais_tb_lista]
GO
ALTER TABLE [dbo].[tb_tipos_lancamentos_manuais]  WITH CHECK ADD  CONSTRAINT [fk_tipo_lancamento_manual_usuario_criacao] FOREIGN KEY([plm_cd_usuario_criacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_tipos_lancamentos_manuais] CHECK CONSTRAINT [fk_tipo_lancamento_manual_usuario_criacao]
GO
ALTER TABLE [dbo].[tb_tipos_lancamentos_manuais]  WITH CHECK ADD  CONSTRAINT [fk_tipo_lancamento_manual_usuario_modificacao] FOREIGN KEY([plm_cd_usuario_modificacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_tipos_lancamentos_manuais] CHECK CONSTRAINT [fk_tipo_lancamento_manual_usuario_modificacao]
GO
ALTER TABLE [dbo].[tb_transferencias]  WITH CHECK ADD  CONSTRAINT [fk_tb_transferencias_clientes] FOREIGN KEY([tra_cd_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_transferencias] CHECK CONSTRAINT [fk_tb_transferencias_clientes]
GO
ALTER TABLE [dbo].[tb_transferencias]  WITH CHECK ADD  CONSTRAINT [fk_tb_transferencias_motoristas] FOREIGN KEY([tra_cd_motorista])
REFERENCES [dbo].[tb_motorista] ([mot_cd_motorista])
GO
ALTER TABLE [dbo].[tb_transferencias] CHECK CONSTRAINT [fk_tb_transferencias_motoristas]
GO
ALTER TABLE [dbo].[tb_transferencias]  WITH CHECK ADD  CONSTRAINT [fk_tb_transferencias_usuario_gestor] FOREIGN KEY([tra_cd_usuario_gestor])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_transferencias] CHECK CONSTRAINT [fk_tb_transferencias_usuario_gestor]
GO
ALTER TABLE [dbo].[tb_transferencias]  WITH CHECK ADD  CONSTRAINT [fk_tb_transferencias_veiculos] FOREIGN KEY([tra_cd_veiculo])
REFERENCES [dbo].[tb_veiculos] ([vei_cd_veiculo])
GO
ALTER TABLE [dbo].[tb_transferencias] CHECK CONSTRAINT [fk_tb_transferencias_veiculos]
GO
ALTER TABLE [dbo].[tb_transferencias_checklists]  WITH CHECK ADD  CONSTRAINT [fk_tb_transferencias_checklists_transferencias] FOREIGN KEY([tch_cd_transferencia])
REFERENCES [dbo].[tb_transferencias] ([tra_cd_transferencia])
GO
ALTER TABLE [dbo].[tb_transferencias_checklists] CHECK CONSTRAINT [fk_tb_transferencias_checklists_transferencias]
GO
ALTER TABLE [dbo].[tb_transferencias_checklists_justificativas]  WITH CHECK ADD  CONSTRAINT [fk_tb_transferencias_checklists_justificativas] FOREIGN KEY([tcj_cd_transferencia_checklist])
REFERENCES [dbo].[tb_transferencias_checklists] ([tch_cd_checklist])
GO
ALTER TABLE [dbo].[tb_transferencias_checklists_justificativas] CHECK CONSTRAINT [fk_tb_transferencias_checklists_justificativas]
GO
ALTER TABLE [dbo].[tb_trg_CIOT]  WITH CHECK ADD  CONSTRAINT [FK_tb_trg_CIOT_IdMotorista] FOREIGN KEY([IdMotorista])
REFERENCES [dbo].[tb_motorista] ([mot_cd_motorista])
GO
ALTER TABLE [dbo].[tb_trg_CIOT] CHECK CONSTRAINT [FK_tb_trg_CIOT_IdMotorista]
GO
ALTER TABLE [dbo].[tb_trg_CIOT]  WITH CHECK ADD  CONSTRAINT [FK_tb_trg_CIOT_IdTransportador] FOREIGN KEY([IdTransportador])
REFERENCES [dbo].[tb_motorista] ([mot_cd_motorista])
GO
ALTER TABLE [dbo].[tb_trg_CIOT] CHECK CONSTRAINT [FK_tb_trg_CIOT_IdTransportador]
GO
ALTER TABLE [dbo].[tb_trg_CIOTParcelas]  WITH CHECK ADD  CONSTRAINT [FK_tb_trg_CI__IdCio__33D580EF] FOREIGN KEY([IdCiot])
REFERENCES [dbo].[tb_trg_CIOT] ([IdCiot])
GO
ALTER TABLE [dbo].[tb_trg_CIOTParcelas] CHECK CONSTRAINT [FK_tb_trg_CI__IdCio__33D580EF]
GO
ALTER TABLE [dbo].[tb_trg_CIOTVeiculos]  WITH CHECK ADD FOREIGN KEY([IdCiot])
REFERENCES [dbo].[tb_trg_CIOT] ([IdCiot])
GO
ALTER TABLE [dbo].[tb_usuario]  WITH CHECK ADD  CONSTRAINT [fk_usr_tipo_contrato] FOREIGN KEY([usr_cd_tipo_contrato])
REFERENCES [dbo].[tb_tipo_contrato] ([ttc_cd_tipo_contrato])
GO
ALTER TABLE [dbo].[tb_usuario] CHECK CONSTRAINT [fk_usr_tipo_contrato]
GO
ALTER TABLE [dbo].[tb_usuario]  WITH CHECK ADD  CONSTRAINT [fk_usr_usr_criacao] FOREIGN KEY([usr_cd_usr_criacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_usuario] CHECK CONSTRAINT [fk_usr_usr_criacao]
GO
ALTER TABLE [dbo].[tb_usuario]  WITH CHECK ADD  CONSTRAINT [fk_usr_usr_modificacao] FOREIGN KEY([usr_cd_usr_modificacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_usuario] CHECK CONSTRAINT [fk_usr_usr_modificacao]
GO
ALTER TABLE [dbo].[tb_usuario]  WITH CHECK ADD  CONSTRAINT [fk_usr_usr_responsavel_contrato] FOREIGN KEY([usr_cd_usr_responsavel_contrato])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_usuario] CHECK CONSTRAINT [fk_usr_usr_responsavel_contrato]
GO
ALTER TABLE [dbo].[tb_usuario]  WITH CHECK ADD  CONSTRAINT [FK_usuario_cliente] FOREIGN KEY([cli_cd_codigo_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_usuario] CHECK CONSTRAINT [FK_usuario_cliente]
GO
ALTER TABLE [dbo].[tb_usuario_grupo_acesso]  WITH CHECK ADD  CONSTRAINT [fk_uga_pga_cd_grupo_acesso] FOREIGN KEY([uga_cd_grupo_acesso])
REFERENCES [dbo].[tb_grupo_acesso] ([gpa_cd_grupo_acesso])
GO
ALTER TABLE [dbo].[tb_usuario_grupo_acesso] CHECK CONSTRAINT [fk_uga_pga_cd_grupo_acesso]
GO
ALTER TABLE [dbo].[tb_usuario_grupo_acesso]  WITH CHECK ADD  CONSTRAINT [fk_uga_usr_cd_usuario] FOREIGN KEY([uga_cd_usuario])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_usuario_grupo_acesso] CHECK CONSTRAINT [fk_uga_usr_cd_usuario]
GO
ALTER TABLE [dbo].[tb_usuario_setor]  WITH CHECK ADD  CONSTRAINT [fk_tb_usuario_setor_tb_clientes] FOREIGN KEY([use_cd_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_usuario_setor] CHECK CONSTRAINT [fk_tb_usuario_setor_tb_clientes]
GO
ALTER TABLE [dbo].[tb_usuario_setor]  WITH CHECK ADD  CONSTRAINT [fk_tb_usuario_setor_tb_setor] FOREIGN KEY([use_cd_setor])
REFERENCES [dbo].[tb_setor] ([set_cd_setor])
GO
ALTER TABLE [dbo].[tb_usuario_setor] CHECK CONSTRAINT [fk_tb_usuario_setor_tb_setor]
GO
ALTER TABLE [dbo].[tb_usuario_setor]  WITH CHECK ADD  CONSTRAINT [fk_tb_usuario_setor_tb_usuario] FOREIGN KEY([use_cd_usuario])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_usuario_setor] CHECK CONSTRAINT [fk_tb_usuario_setor_tb_usuario]
GO
ALTER TABLE [dbo].[tb_validacao_rotas]  WITH CHECK ADD  CONSTRAINT [fk_validacao_rotas_status] FOREIGN KEY([vrt_cd_status_validacao])
REFERENCES [dbo].[tb_lista] ([lst_cd_lista])
GO
ALTER TABLE [dbo].[tb_validacao_rotas] CHECK CONSTRAINT [fk_validacao_rotas_status]
GO
ALTER TABLE [dbo].[tb_validacoes_espelho]  WITH CHECK ADD  CONSTRAINT [fk_tb_validacoes_espelho_tipo] FOREIGN KEY([vle_cd_tipo_validacao])
REFERENCES [dbo].[tb_lista] ([lst_cd_lista])
GO
ALTER TABLE [dbo].[tb_validacoes_espelho] CHECK CONSTRAINT [fk_tb_validacoes_espelho_tipo]
GO
ALTER TABLE [dbo].[tb_validacoes_espelho]  WITH CHECK ADD  CONSTRAINT [fk_tb_validacoes_espelho_usuario_criacao] FOREIGN KEY([vle_cd_usuario_criacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_validacoes_espelho] CHECK CONSTRAINT [fk_tb_validacoes_espelho_usuario_criacao]
GO
ALTER TABLE [dbo].[tb_validacoes_espelho]  WITH CHECK ADD  CONSTRAINT [fk_tb_validacoes_espelho_usuario_modificacao] FOREIGN KEY([vle_cd_usuario_modificacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_validacoes_espelho] CHECK CONSTRAINT [fk_tb_validacoes_espelho_usuario_modificacao]
GO
ALTER TABLE [dbo].[tb_validacoes_espelho_config]  WITH CHECK ADD  CONSTRAINT [fk_tb_validacoes_espelho_config_cliente] FOREIGN KEY([veg_cd_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_validacoes_espelho_config] CHECK CONSTRAINT [fk_tb_validacoes_espelho_config_cliente]
GO
ALTER TABLE [dbo].[tb_validacoes_espelho_config]  WITH CHECK ADD  CONSTRAINT [fk_tb_validacoes_espelho_config_contexto] FOREIGN KEY([veg_cd_validacao_contexto])
REFERENCES [dbo].[tb_validacoes_espelho_contexto] ([vec_cd_validacao_contexto])
GO
ALTER TABLE [dbo].[tb_validacoes_espelho_config] CHECK CONSTRAINT [fk_tb_validacoes_espelho_config_contexto]
GO
ALTER TABLE [dbo].[tb_validacoes_espelho_config]  WITH CHECK ADD  CONSTRAINT [fk_tb_validacoes_espelho_config_usuario_criacao] FOREIGN KEY([veg_cd_usuario_criacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_validacoes_espelho_config] CHECK CONSTRAINT [fk_tb_validacoes_espelho_config_usuario_criacao]
GO
ALTER TABLE [dbo].[tb_validacoes_espelho_config]  WITH CHECK ADD  CONSTRAINT [fk_tb_validacoes_espelho_config_usuario_modificacao] FOREIGN KEY([veg_cd_usuario_modificacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_validacoes_espelho_config] CHECK CONSTRAINT [fk_tb_validacoes_espelho_config_usuario_modificacao]
GO
ALTER TABLE [dbo].[tb_validacoes_espelho_contexto]  WITH CHECK ADD  CONSTRAINT [fk_tb_validacoes_espelho_contexto_cliente_transportadora] FOREIGN KEY([vec_cd_validacao_contexto])
REFERENCES [dbo].[tb_lista] ([lst_cd_lista])
GO
ALTER TABLE [dbo].[tb_validacoes_espelho_contexto] CHECK CONSTRAINT [fk_tb_validacoes_espelho_contexto_cliente_transportadora]
GO
ALTER TABLE [dbo].[tb_validacoes_espelho_contexto]  WITH CHECK ADD  CONSTRAINT [fk_tb_validacoes_espelho_contexto_operacao] FOREIGN KEY([vec_cd_validacao_contexto])
REFERENCES [dbo].[tb_lista] ([lst_cd_lista])
GO
ALTER TABLE [dbo].[tb_validacoes_espelho_contexto] CHECK CONSTRAINT [fk_tb_validacoes_espelho_contexto_operacao]
GO
ALTER TABLE [dbo].[tb_validacoes_espelho_contexto]  WITH CHECK ADD  CONSTRAINT [fk_tb_validacoes_espelho_contexto_usuario_criacao] FOREIGN KEY([vec_cd_usuario_criacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_validacoes_espelho_contexto] CHECK CONSTRAINT [fk_tb_validacoes_espelho_contexto_usuario_criacao]
GO
ALTER TABLE [dbo].[tb_validacoes_espelho_contexto]  WITH CHECK ADD  CONSTRAINT [fk_tb_validacoes_espelho_contexto_usuario_modificacao] FOREIGN KEY([vec_cd_usuario_modificacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_validacoes_espelho_contexto] CHECK CONSTRAINT [fk_tb_validacoes_espelho_contexto_usuario_modificacao]
GO
ALTER TABLE [dbo].[tb_validacoes_espelho_contexto]  WITH CHECK ADD  CONSTRAINT [fk_tb_validacoes_espelho_contexto_validacao] FOREIGN KEY([vec_cd_validacao])
REFERENCES [dbo].[tb_validacoes_espelho] ([vle_cd_validacao])
GO
ALTER TABLE [dbo].[tb_validacoes_espelho_contexto] CHECK CONSTRAINT [fk_tb_validacoes_espelho_contexto_validacao]
GO
ALTER TABLE [dbo].[tb_validacoes_espelho_resultados]  WITH CHECK ADD  CONSTRAINT [fk_tb_validacoes_espelho_resultados_contexto] FOREIGN KEY([ver_cd_validacao_contexto])
REFERENCES [dbo].[tb_validacoes_espelho_contexto] ([vec_cd_validacao_contexto])
GO
ALTER TABLE [dbo].[tb_validacoes_espelho_resultados] CHECK CONSTRAINT [fk_tb_validacoes_espelho_resultados_contexto]
GO
ALTER TABLE [dbo].[tb_validacoes_espelho_resultados]  WITH CHECK ADD  CONSTRAINT [fk_tb_validacoes_espelho_resultados_pagamento_lancamento_manual] FOREIGN KEY([ver_cd_lancamento_manual])
REFERENCES [dbo].[tb_lancamentos_manuais] ([tlm_cd_lancamento_manual])
GO
ALTER TABLE [dbo].[tb_validacoes_espelho_resultados] CHECK CONSTRAINT [fk_tb_validacoes_espelho_resultados_pagamento_lancamento_manual]
GO
ALTER TABLE [dbo].[tb_validacoes_espelho_resultados]  WITH CHECK ADD  CONSTRAINT [fk_tb_validacoes_espelho_resultados_pagamento_rota] FOREIGN KEY([ver_cd_pagamento_rota])
REFERENCES [dbo].[tb_pgto_periodo_rota] ([ppr_cd_pagamento_rota])
GO
ALTER TABLE [dbo].[tb_validacoes_espelho_resultados] CHECK CONSTRAINT [fk_tb_validacoes_espelho_resultados_pagamento_rota]
GO
ALTER TABLE [dbo].[tb_validacoes_espelho_resultados]  WITH CHECK ADD  CONSTRAINT [fk_tb_validacoes_espelho_resultados_pagamento_usuario_inativacao] FOREIGN KEY([ver_cd_usuario_inativacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_validacoes_espelho_resultados] CHECK CONSTRAINT [fk_tb_validacoes_espelho_resultados_pagamento_usuario_inativacao]
GO
ALTER TABLE [dbo].[tb_validacoes_espelho_resultados]  WITH CHECK ADD  CONSTRAINT [fk_tb_validacoes_espelho_resultados_periodo] FOREIGN KEY([ver_cd_periodo])
REFERENCES [dbo].[tb_pgto_periodo] ([pgp_cd_periodo])
GO
ALTER TABLE [dbo].[tb_validacoes_espelho_resultados] CHECK CONSTRAINT [fk_tb_validacoes_espelho_resultados_periodo]
GO
ALTER TABLE [dbo].[tb_validacoes_espelho_resultados_totais]  WITH CHECK ADD  CONSTRAINT [fk_tb_validacoes_espelho_resultados_totais_contexto] FOREIGN KEY([vet_cd_validacao_contexto])
REFERENCES [dbo].[tb_validacoes_espelho_contexto] ([vec_cd_validacao_contexto])
GO
ALTER TABLE [dbo].[tb_validacoes_espelho_resultados_totais] CHECK CONSTRAINT [fk_tb_validacoes_espelho_resultados_totais_contexto]
GO
ALTER TABLE [dbo].[tb_validacoes_espelho_resultados_totais]  WITH CHECK ADD  CONSTRAINT [fk_tb_validacoes_espelho_resultados_totais_periodo] FOREIGN KEY([vet_cd_periodo])
REFERENCES [dbo].[tb_pgto_periodo] ([pgp_cd_periodo])
GO
ALTER TABLE [dbo].[tb_validacoes_espelho_resultados_totais] CHECK CONSTRAINT [fk_tb_validacoes_espelho_resultados_totais_periodo]
GO
ALTER TABLE [dbo].[tb_validacoes_gerais_config]  WITH CHECK ADD  CONSTRAINT [fk_validacao_config_cliente] FOREIGN KEY([vlc_cd_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_validacoes_gerais_config] CHECK CONSTRAINT [fk_validacao_config_cliente]
GO
ALTER TABLE [dbo].[tb_validacoes_gerais_config]  WITH CHECK ADD  CONSTRAINT [tb_validacoes_gerais_config_cad] FOREIGN KEY([vlc_cd_validacao])
REFERENCES [dbo].[tb_validacoes_gerais] ([vld_cd_validacao])
GO
ALTER TABLE [dbo].[tb_validacoes_gerais_config] CHECK CONSTRAINT [tb_validacoes_gerais_config_cad]
GO
ALTER TABLE [dbo].[tb_validacoes_gerais_resultados]  WITH CHECK ADD  CONSTRAINT [fk_vld_validacao_cliente_resultados] FOREIGN KEY([vlr_cd_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_validacoes_gerais_resultados] CHECK CONSTRAINT [fk_vld_validacao_cliente_resultados]
GO
ALTER TABLE [dbo].[tb_validacoes_gerais_resultados]  WITH CHECK ADD  CONSTRAINT [fk_vld_validacao_resultados] FOREIGN KEY([vlr_cd_validacao])
REFERENCES [dbo].[tb_validacoes_gerais] ([vld_cd_validacao])
GO
ALTER TABLE [dbo].[tb_validacoes_gerais_resultados] CHECK CONSTRAINT [fk_vld_validacao_resultados]
GO
ALTER TABLE [dbo].[tb_veiculos]  WITH NOCHECK ADD  CONSTRAINT [fk_cd_veiculo_aluguel] FOREIGN KEY([vei_cd_vl_aluguel])
REFERENCES [dbo].[tb_vl_veiculo_aluguel] ([vva_cd_alguel])
GO
ALTER TABLE [dbo].[tb_veiculos] NOCHECK CONSTRAINT [fk_cd_veiculo_aluguel]
GO
ALTER TABLE [dbo].[tb_veiculos]  WITH CHECK ADD  CONSTRAINT [FK_tb_veiculos_cd_cliente] FOREIGN KEY([vei_cd_cliente])
REFERENCES [dbo].[tb_clientes] ([cli_cd_codigo_cliente])
GO
ALTER TABLE [dbo].[tb_veiculos] CHECK CONSTRAINT [FK_tb_veiculos_cd_cliente]
GO
ALTER TABLE [dbo].[tb_veiculos]  WITH CHECK ADD  CONSTRAINT [fk_tb_veiculos_usuario_criacao] FOREIGN KEY([vei_cd_usuario_criacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_veiculos] CHECK CONSTRAINT [fk_tb_veiculos_usuario_criacao]
GO
ALTER TABLE [dbo].[tb_veiculos]  WITH CHECK ADD  CONSTRAINT [fk_tb_veiculos_usuario_modificacao] FOREIGN KEY([vei_cd_usuario_modificacao])
REFERENCES [dbo].[tb_usuario] ([usr_cd_usuario])
GO
ALTER TABLE [dbo].[tb_veiculos] CHECK CONSTRAINT [fk_tb_veiculos_usuario_modificacao]
GO
ALTER TABLE [dbo].[tb_vl_veiculo_aluguel]  WITH CHECK ADD  CONSTRAINT [fk_vl_veiculo_aluguel] FOREIGN KEY([vva_cd_tipo_veiculo])
REFERENCES [dbo].[tb_dra_tipo_veiculo] ([tvl_cd_tipo_veiculo])
GO
ALTER TABLE [dbo].[tb_vl_veiculo_aluguel] CHECK CONSTRAINT [fk_vl_veiculo_aluguel]
GO
ALTER TABLE [dbo].[tb_acao_gps]  WITH CHECK ADD  CONSTRAINT [ck_acao_gps_tipo] CHECK  (([agp_ds_acao]='F' OR [agp_ds_acao]='I'))
GO
ALTER TABLE [dbo].[tb_acao_gps] CHECK CONSTRAINT [ck_acao_gps_tipo]
GO
ALTER TABLE [dbo].[tb_cidades_regiao_nao_identificadas_api]  WITH CHECK ADD  CONSTRAINT [CK_lat_range] CHECK  (([LatitudeMin]<=[LatitudeMax]))
GO
ALTER TABLE [dbo].[tb_cidades_regiao_nao_identificadas_api] CHECK CONSTRAINT [CK_lat_range]
GO
ALTER TABLE [dbo].[tb_cidades_regiao_nao_identificadas_api]  WITH CHECK ADD  CONSTRAINT [CK_long_range] CHECK  (([LongitudeMin]<=[LongitudeMax]))
GO
ALTER TABLE [dbo].[tb_cidades_regiao_nao_identificadas_api] CHECK CONSTRAINT [CK_long_range]
GO
ALTER TABLE [dbo].[tb_fin_base_frete_adicional_motorista]  WITH CHECK ADD  CONSTRAINT [CK_tb_fin_base_frete_adicional_motorista_bfa_nm_cidade_nao_vazio] CHECK  (([bfa_nm_cidade]<>''))
GO
ALTER TABLE [dbo].[tb_fin_base_frete_adicional_motorista] CHECK CONSTRAINT [CK_tb_fin_base_frete_adicional_motorista_bfa_nm_cidade_nao_vazio]
GO
ALTER TABLE [dbo].[tb_fin_base_frete_adicional_motorista]  WITH CHECK ADD  CONSTRAINT [CK_tb_fin_base_frete_adicional_motorista_bfa_placa_nao_vazio] CHECK  (([bfa_ds_placa]<>''))
GO
ALTER TABLE [dbo].[tb_fin_base_frete_adicional_motorista] CHECK CONSTRAINT [CK_tb_fin_base_frete_adicional_motorista_bfa_placa_nao_vazio]
GO
ALTER TABLE [dbo].[tb_fin_base_frete_motorista]  WITH CHECK ADD  CONSTRAINT [CK_tb_fin_base_frete_motorista_bfm_nm_cidade_nao_vazio] CHECK  (([bfm_nm_cidade]<>''))
GO
ALTER TABLE [dbo].[tb_fin_base_frete_motorista] CHECK CONSTRAINT [CK_tb_fin_base_frete_motorista_bfm_nm_cidade_nao_vazio]
GO
ALTER TABLE [dbo].[tb_fin_base_frete_motorista]  WITH CHECK ADD  CONSTRAINT [CK_tb_fin_base_frete_motorista_bfm_placa_nao_vazio] CHECK  (([bfm_ds_placa]<>''))
GO
ALTER TABLE [dbo].[tb_fin_base_frete_motorista] CHECK CONSTRAINT [CK_tb_fin_base_frete_motorista_bfm_placa_nao_vazio]
GO
ALTER TABLE [dbo].[tb_fin_base_frete_motorista]  WITH CHECK ADD  CONSTRAINT [CK_tb_fin_base_frete_motorista_Faixa2] CHECK  (([bfm_vl_inicio_faixa2] IS NULL OR [bfm_cd_criterio_faixa2] IS NOT NULL))
GO
ALTER TABLE [dbo].[tb_fin_base_frete_motorista] CHECK CONSTRAINT [CK_tb_fin_base_frete_motorista_Faixa2]
GO
ALTER TABLE [dbo].[tb_fin_base_frete_motorista]  WITH CHECK ADD  CONSTRAINT [CK_tb_fin_base_frete_motorista_pagamento] CHECK  ((NOT ([bfm_pag_pacote]=(1) AND [bfm_pag_pacote_entregues]=(1))))
GO
ALTER TABLE [dbo].[tb_fin_base_frete_motorista] CHECK CONSTRAINT [CK_tb_fin_base_frete_motorista_pagamento]
GO
ALTER TABLE [dbo].[tb_fin_salarios_profissionais]  WITH CHECK ADD  CONSTRAINT [chk_periodo_salarios_profissionais] CHECK  (([tsp_dt_fim] IS NULL OR [tsp_dt_fim]>[tsp_dt_inicio]))
GO
ALTER TABLE [dbo].[tb_fin_salarios_profissionais] CHECK CONSTRAINT [chk_periodo_salarios_profissionais]
GO
ALTER TABLE [dbo].[tb_imp_importador_coluna]  WITH CHECK ADD  CONSTRAINT [CK_tb_imp_importador_coluna_tipo] CHECK  (([imc_ds_tipo_dado]='BOOLEANO' OR [imc_ds_tipo_dado]='DATA' OR [imc_ds_tipo_dado]='DECIMAL' OR [imc_ds_tipo_dado]='NUMERO' OR [imc_ds_tipo_dado]='TEXTO'))
GO
ALTER TABLE [dbo].[tb_imp_importador_coluna] CHECK CONSTRAINT [CK_tb_imp_importador_coluna_tipo]
GO
ALTER TABLE [dbo].[tb_imp_log_coluna_erro]  WITH CHECK ADD  CONSTRAINT [CK_tb_imp_log_coluna_erro_tipo] CHECK  (([ice_ds_tipo_erro]='OUTRO' OR [ice_ds_tipo_erro]='VALOR_INVALIDO' OR [ice_ds_tipo_erro]='DUPLICADO' OR [ice_ds_tipo_erro]='TIPO_INVALIDO' OR [ice_ds_tipo_erro]='COLUNA_AUSENTE'))
GO
ALTER TABLE [dbo].[tb_imp_log_coluna_erro] CHECK CONSTRAINT [CK_tb_imp_log_coluna_erro_tipo]
GO
ALTER TABLE [dbo].[tb_indisponibilidade_motorista]  WITH CHECK ADD  CONSTRAINT [CK_indisponibilidade_ciclo] CHECK  (([idp_ds_ciclo]='PM' OR [idp_ds_ciclo]='AM'))
GO
ALTER TABLE [dbo].[tb_indisponibilidade_motorista] CHECK CONSTRAINT [CK_indisponibilidade_ciclo]
GO
ALTER TABLE [dbo].[tb_motorista]  WITH CHECK ADD  CONSTRAINT [CHK_mot_gr_nm_pais_motorista] CHECK  (([mot_gr_nm_pais_motorista] IS NULL OR [mot_gr_nm_pais_motorista]>=(0) AND [mot_gr_nm_pais_motorista]<=(99)))
GO
ALTER TABLE [dbo].[tb_motorista] CHECK CONSTRAINT [CHK_mot_gr_nm_pais_motorista]
GO
ALTER TABLE [dbo].[tb_motorista]  WITH CHECK ADD  CONSTRAINT [CHK_mot_gr_nm_tipo_motorista] CHECK  (([mot_gr_nm_tipo_motorista] IS NULL OR [mot_gr_nm_tipo_motorista]>=(0) AND [mot_gr_nm_tipo_motorista]<=(99)))
GO
ALTER TABLE [dbo].[tb_motorista] CHECK CONSTRAINT [CHK_mot_gr_nm_tipo_motorista]
GO
ALTER TABLE [dbo].[tb_motorista]  WITH CHECK ADD  CONSTRAINT [CHK_mot_gr_nm_tipo_nacionalidade] CHECK  (([mot_gr_nm_tipo_nacionalidade] IS NULL OR [mot_gr_nm_tipo_nacionalidade]>=(0) AND [mot_gr_nm_tipo_nacionalidade]<=(999)))
GO
ALTER TABLE [dbo].[tb_motorista] CHECK CONSTRAINT [CHK_mot_gr_nm_tipo_nacionalidade]
GO
ALTER TABLE [dbo].[tb_pbi_mon_processo]  WITH CHECK ADD  CONSTRAINT [CK_tb_pbi_mon_processo_acao_habilitada] CHECK  (([in_acao_habilitada]=(0) OR [proc_acao] IS NOT NULL))
GO
ALTER TABLE [dbo].[tb_pbi_mon_processo] CHECK CONSTRAINT [CK_tb_pbi_mon_processo_acao_habilitada]
GO
ALTER TABLE [dbo].[tb_pbi_mon_processo]  WITH CHECK ADD  CONSTRAINT [CK_tb_pbi_mon_processo_acao_params_json] CHECK  (([proc_acao_params] IS NULL OR isjson([proc_acao_params])=(1) AND left(ltrim([proc_acao_params]),(1))='['))
GO
ALTER TABLE [dbo].[tb_pbi_mon_processo] CHECK CONSTRAINT [CK_tb_pbi_mon_processo_acao_params_json]
GO
ALTER TABLE [dbo].[tb_pbi_mon_processo]  WITH CHECK ADD  CONSTRAINT [CK_tb_pbi_mon_processo_destino_regra] CHECK  (([destino_regra]=N'NULOS' OR [destino_regra]=N'FRESHNESS'))
GO
ALTER TABLE [dbo].[tb_pbi_mon_processo] CHECK CONSTRAINT [CK_tb_pbi_mon_processo_destino_regra]
GO
ALTER TABLE [dbo].[tb_pbi_mon_processo]  WITH CHECK ADD  CONSTRAINT [CK_tb_pbi_mon_processo_id_cliente_campo] CHECK  (([id_cliente_campo]=N'cli_id_shopee' OR [id_cliente_campo]=N'cli_id_logistics'))
GO
ALTER TABLE [dbo].[tb_pbi_mon_processo] CHECK CONSTRAINT [CK_tb_pbi_mon_processo_id_cliente_campo]
GO
ALTER TABLE [dbo].[tb_pbi_mon_processo]  WITH CHECK ADD  CONSTRAINT [CK_tb_pbi_mon_processo_tipo_regra] CHECK  (([tipo_regra]=N'LOOKER_DIARIO' OR [tipo_regra]=N'PIPELINE_5MIN'))
GO
ALTER TABLE [dbo].[tb_pbi_mon_processo] CHECK CONSTRAINT [CK_tb_pbi_mon_processo_tipo_regra]
GO
ALTER TABLE [dbo].[tb_pbi_mon_processo_acao_log]  WITH CHECK ADD  CONSTRAINT [CK_tb_pbi_mon_processo_acao_log_params_json] CHECK  (([ds_parametros_json] IS NULL OR isjson([ds_parametros_json])=(1)))
GO
ALTER TABLE [dbo].[tb_pbi_mon_processo_acao_log] CHECK CONSTRAINT [CK_tb_pbi_mon_processo_acao_log_params_json]
GO
ALTER TABLE [dbo].[tb_periodos_espelhos_pagamento]  WITH CHECK ADD  CONSTRAINT [chk_periodo] CHECK  (([pep_dt_inicio]<=[pep_dt_fim]))
GO
ALTER TABLE [dbo].[tb_periodos_espelhos_pagamento] CHECK CONSTRAINT [chk_periodo]
GO
ALTER TABLE [dbo].[tb_sessao_usuario]  WITH CHECK ADD  CONSTRAINT [CK_sessao_tp_login] CHECK  (([ssu_tp_login]=(1) OR [ssu_tp_login]=(2)))
GO
ALTER TABLE [dbo].[tb_sessao_usuario] CHECK CONSTRAINT [CK_sessao_tp_login]
GO
