-- ============================================================
-- BASELINE: dbo.vw_feriados
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_feriados]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vw_feriados] as

select 
    tfd_cd_cliente      as IdCliente,
    bss_cd_idtransportadora as idtransportadora,
    bss_ds_sigla        as servicecenter,
    a.Data,
    1                   as Feriado
from 
    DimData as a with (nolock)
    inner join [tb_feriados] as b with (nolock)
        on a.data = b.tfd_dh_feriado
    left join tb_bases as c with (nolock)
        on  bss_cod_cliente = tfd_cd_cliente
        and (
                bss_ds_estado    = tfd_ds_estado
             or tfd_ds_municipio = bss_ds_cidade
             or tfd_tipo_feriado = 'Nacional'
            )
where 
    tfd_in_excluido = 0
    and tfd_cd_cliente <> 7
GO
