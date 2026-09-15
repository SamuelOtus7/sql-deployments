-- ============================================================
-- BASELINE: dbo.vw_fin_definie_cidade_distrito
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_fin_definie_cidade_distrito]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vw_fin_definie_cidade_distrito] as 

select 
   bss_ds_sigla as Base
  ,ttc_nm_tipo as Contrato
  ,nome as Estado
  ,cid_ds_cidade as Cidade
  ,NomeDistrito as Distrito
   ,lst_ds_label as Regiao
  ,fcd_cd_cliente

from  tb_fin_definie_cidade_distrito as a

inner join tb_tipo_contrato as contrato
on fcd_cd_contrato = ttc_cd_tipo_contrato

inner join tb_bases as base
on fcd_cd_Base = bss_cd_base

inner join [tb_codigos_cidades] as cidade
on fcd_cd_cidade = cid_cd_cidade

inner join tb_fin_distritos_cadastrados as distrito
on fcd_cd_distrito = IdDistrito

inner join [tb_estados_ibge] as estado
on a.fcd_cd_estado = estado.id

inner join tb_clientes as tenant
on fcd_cd_cliente = cli_cd_codigo_cliente


inner join tb_lista as list
on fcd_cd_regiao = lst_cd_lista
--select 758,312,1991,9266, 5

 
GO
