-- ============================================================
-- BASELINE: dbo.UspMLRegistroInsucessos
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLRegistroInsucessos]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[UspMLRegistroInsucessos]
as

BEGIN
--declare @datainicio date = getdate()-2
declare @datainicio date = getdate()-3 -- Código acima comentado pois não escata usando os indices do dia atual
declare @datafim date = getdate()


drop table if exists #tabela
select 
    
     a.IdTransportadora
    ,a.DataReferencia
    ,a.IdRota	
    ,a.IdPacote	
    ,b.NomeMotorista
    ,b.ServiceCenter
    ,b.OrigemSaida as XPT
    ,a.NomeEtiqueta
    
    ,t.tds_ds_traducao StatusEntrega
    ,case  
        when t3.tds_ds_traducao = 'Endereço Ruim' then 'Endereço inválido'
        when t3.tds_ds_traducao = 'Erro de Rota' then 'Fora de Área'
        else isnull(t3.tds_ds_traducao,'Não Categorizado') end  SubStatus
    
    ,b.statusrota
    ,a.Endereco
    ,a.EnderecoParada
    ,a.QuantidadeReclamacoes	
    ,a.ForaAreaEntrega
    
into #tabela

from tb_ml_pacotes as a WITH (NOLOCK)

inner join tb_ml_rotas as b WITH (NOLOCK)
on a.DataReferencia = b.DataReferencia
and a.IdTransportadora = b.IdTransportadora
and a.idrota = b.IdRota

left join tb_ml_traducoes t  on a.StatusEntrega = t.tds_vl_json and t.tds_nm_tabela = 'tb_ml_pacotes' and t.tds_nm_campo = 'StatusEntrega'
left join tb_ml_traducoes t2 on a.TipoEndereco = t2.tds_vl_json and t2.tds_nm_tabela = 'tb_ml_pacotes' and t2.tds_nm_campo = 'TipoEndereco'
left join tb_ml_traducoes t3 on a.SubStatus = t3.tds_vl_json and t3.tds_nm_tabela = 'tb_ml_pacotes' and t3.tds_nm_campo = 'SubStatus'


where 1=1 
and a.DataReferencia  BETWEEN @datainicio and @datafim
--and a.idtransportadora  = 1950609251
and a.StatusEntrega = 'not_delivered'
and a.Excluido = 0
and b.Excluido = 0
and isnull(a.SubStatus,'') <> 'transferred'
and statusrota <> 'planned' 

--atualiza tabela de insucesso
merge tb_ml_hist_insucesso as target
using #tabela as source
on target.IdTransportadora = source.IdTransportadora
and target.DataReferencia = source.DataReferencia
and target.IdRota = source.IdRota
and target.IdPacote = source.IdPacote
when not matched then
insert 
(
     IdTransportadora
    ,DataReferencia
    ,IdRota	
    ,IdPacote	
    ,NomeMotorista
    ,ServiceCenter
    ,XPT
    ,NomeEtiqueta
    ,StatusEntrega
    ,SubStatus
    ,statusrota
    ,Endereco
    ,EnderecoParada
    ,QuantidadeReclamacoes	
    ,ForaAreaEntrega

)
values
(
     source.IdTransportadora
    ,source.DataReferencia
    ,source.IdRota	
    ,source.IdPacote	
    ,source.NomeMotorista
    ,source.ServiceCenter
    ,source.XPT
    ,source.NomeEtiqueta
    ,source.StatusEntrega
    ,source.SubStatus
    ,source.statusrota
    ,source.Endereco
    ,source.EnderecoParada
    ,source.QuantidadeReclamacoes	
    ,source.ForaAreaEntrega
);




--reverte pacotes por outra transportadora
drop table if exists #tabela_revertido_outra_rota
select 
    a.CodInsucesso
    ,a.idtransportadora
    ,a.idrota
    ,b.IdRota as IdRotaRevertida
    ,case when a.idrota = b.IdRota then 0 else 1 end as RevertidoOutraRota
    ,a.IdPacote
    ,1 as Revertido
    ,cast(b.DataHoraEntrega as date) as DataReversao
    ,ROW_NUMBER() over (partition by a.IdPacote order by b.DataReferencia desc) as OrdemReversao
    ,datepart(hour, b.DataHoraEntrega) as HoraReversao

into #tabela_revertido_outra_rota

from tb_ml_hist_insucesso as a
inner join tb_ml_pacotes as b
on a.idpacote = b.IdPacote

where 1=1 
--and b.DataReferencia  BETWEEN @datainicio and @datafim
and  b.StatusEntrega = 'delivered'
and b.Excluido = 0 

--atualiza reversao dos pacotes por outra transportadora
merge tb_ml_hist_insucesso as target
using #tabela_revertido_outra_rota as source
on target.IdTransportadora = source.IdTransportadora
and target.IdPacote = source.IdPacote
and target.idrota = source.IdRota
and source.OrdemReversao = 1
and target.datareferencia = source.datareversao

when matched then   
update set 
    target.Revertido = source.Revertido,
    target.RevertidoOutraRota = source.RevertidoOutraRota,
    target.IdRotaRevertida = source.IdRotaRevertida,
    target.DataReversao = source.DataReversao,
	target.HoraReversao = source.HoraReversao
	;


end


-- select * from tb_ml_pacotes where IdPacote = 44541960388
-- select * from tb_ml_hist_insucesso where Revertido	= 1 and RevertidoOutraRota = 0
-- select * from #tabela_revertido_outra_rota where IdPacote = 44541960388
 
-- and b.idpacote  = 44541960388
GO
