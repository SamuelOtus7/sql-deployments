-- ============================================================
-- BASELINE: dbo.UspSPEAtualizaPacotesPendentes
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPEAtualizaPacotesPendentes]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspSPEAtualizaPacotesPendentes] as 

declare @hoje date  = getdate()

---as rotas que ficaram em aberto no dia anterior tem os ospacotes do dia anteiror levados para o dia atual
drop table if exists #pacotes
select 
@hoje as DataNova,
pac.*
into #pacotes
from tb_spe_pacotes_v5 as pac
inner join (
    select distinct  p.codigorota, p.DataReferencia
    from tb_spe_pacotes_v5 as p
    inner join tb_spe_rotas_v5 as r on p.codigorota = r.codigorota and p.DataReferencia = r.DataReferencia
    where  1=1
    and statusentrega = 'Delivering'
    and p.DataReferencia = dateadd(day, -1, @hoje)
   --and p.codigorota = 'TO20250123MG3ZU'
) as p on pac.codigorota = p.codigorota and pac.DataReferencia = p.DataReferencia



insert into tb_spe_pacotes_v5 (
    CodigoRota
    ,CodigoPacote
    ,IdTransportadora
    ,DataReferencia
    ,DataHoraColeta
    ,DataHoraEntrega
    ,StatusEntrega
    ,SubStatus
    ,IdMotorista
    ,RecebidoPor
    ,CEP
    ,Latitude
    ,Longitude
    ,URLImagem
    ,DataAtualizacao
    ,DataAtualizacaoDetalhe
    ,Excluido
    ,SubStatusAnterior
    ,StatusPacote
    ,Cidade
)

select 

    p.CodigoRota
    ,p.CodigoPacote
    ,p.IdTransportadora
    ,p.DataNova as DataReferencia
    ,p.DataHoraColeta
    ,p.DataHoraEntrega
    ,p.StatusEntrega
    ,p.SubStatus
    ,p.IdMotorista
    ,p.RecebidoPor
    ,p.CEP
    ,p.Latitude
    ,p.Longitude
    ,p.URLImagem
    ,p.DataAtualizacao
    ,p.DataAtualizacaoDetalhe
    ,p.Excluido
    ,p.SubStatusAnterior
    ,p.StatusPacote
    ,p.Cidade

from #pacotes as p
left join tb_spe_pacotes_v5 as pac on p.codigorota = pac.codigorota and p.DataNova = pac.DataReferencia and p.CodigoPacote = pac.CodigoPacote
where pac.CodigoRota is null


update pac
set 
    pac.Excluido = 1
from  #pacotes as p
inner join tb_spe_pacotes_v5 as pac on p.codigorota = pac.codigorota and p.DataReferencia = pac.DataReferencia and p.CodigoPacote = pac.CodigoPacote
GO
