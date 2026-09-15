-- ============================================================
-- BASELINE: dbo.UspFinGeraPagamentoAreaRisco
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinGeraPagamentoAreaRisco]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure [dbo].[UspFinGeraPagamentoAreaRisco]   (
@CodPeriodoPagamento int,
@idrota varchar(50) = null) as 

begin

-- declare @CodPeriodoPagamento int =  161

drop table if exists #valoresderisco
select 
     IdRota
    ,ppr_vl_risco
    ,CUSTO
    ,ppr_vl_total
    ,STATUS

    ,isnull(ppr_vl_base,0)      as ppr_vl_Base
    ,isnull(ppr_vl_bonus,0)     as ppr_vl_bonus
    ,isnull(ppr_vl_pedagio,0)   as ppr_vl_pedagio
    ,isnull(ppr_vl_paradas,0)   as ppr_vl_paradas
    ,isnull(ppr_vl_ajudante,0)  as ppr_vl_ajudante
    ,isnull(ppr_vl_dom_fer,0)   as ppr_vl_dom_fer
    ,isnull(ppr_vl_lancamentos,0) as ppr_vl_lancamentos
    ,isnull(ppr_qt_pacotes,0) as ppr_qt_pacotes
    ,nullif(qtd,0) / cast(ppr_qt_pacotes as decimal(10,2)) perc

into #valoresderisco
 
from tb_pgto_periodo_rota as a
inner join ( 
            select distinct 
				idrota  
                ,STATUS
				,CUSTO
				,count(*) qtd
			from [vw_pacotes_areas_risco] 
			where CUSTO is not null 
          --  and idrota  = 174147828
	
			group by idrota  ,CUSTO,STATUS
			) as b
on ppr_cd_rota = b.idrota

where ppr_cd_periodo = @CodPeriodoPagamento
and ppr_ds_tipo_veiculo not like '%SDD%'



------
update  tb_pgto_periodo_rota 
set 
  ppr_vl_risco = case 
                    when perc >= '0.55' and STATUS  = 'Oficial Meli' 
                        then vdr.CUSTO
                    when STATUS  = 'Não Oficial' 
                        then vdr.CUSTO 
                    else 0 end 
, ppr_vl_total =   ( case 
                    when perc >= '0.55' and STATUS  = 'Oficial Meli' 
                        then vdr.CUSTO
                    when STATUS  = 'Não Oficial' 
                        then vdr.CUSTO 
                    else 0 end  + isnull(vdr.ppr_vl_base,0)  + isnull(vdr.ppr_vl_bonus,0) + isnull(vdr.ppr_vl_pedagio,0) + isnull(vdr.ppr_vl_paradas,0) + 
                 isnull(vdr.ppr_vl_ajudante,0) + isnull(vdr.ppr_vl_dom_fer,0) + isnull(vdr.ppr_vl_lancamentos,0)  
                    )
from tb_pgto_periodo_rota as a

inner join  #valoresderisco vdr 
on vdr.idrota = a.ppr_cd_rota 

where ppr_cd_periodo = @CodPeriodoPagamento



-----
update a
set mtn_vl_nfs = total
from tb_pag_espelhos a 
inner join (
	select 
	 sum(ppr_vl_total) as total
	,ppr_cd_pgto_espelho
	from tb_pgto_periodo_rota as a
	where  ppr_cd_pgto_espelho = @CodPeriodoPagamento
	group by ppr_cd_pgto_espelho
) as b
on a.mtn_cd_motorista_nfs = b.ppr_cd_pgto_espelho 


end
GO
