-- ============================================================
-- BASELINE: dbo.UspDimData
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspDimData]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--==================================================
-- Autor: Vitor Ferreira
-- Data de Criação: 01/09/2022
-- Descrição: Carrega dimensão de Datas
--==================================================
create procedure [dbo].[UspDimData]
(
	@DataInicio date,
	@DataFim date
)

as
begin
	
set language 'Português'

;with base as 
(
	select @DataInicio as Data
	union all
	select dateadd(day,1,Data) from base where Data < @DataFim
)

insert into DimData

select cast(convert(varchar,base.Data,112) as int) as SkData,
	   base.Data,
	   day(base.Data) as DiaMes,
	   datepart(weekday,base.Data) as NumDiaSemana,
	   datename(weekday,base.data) as DiaSemana,
	   ceiling(day(base.data) / 10.4) as Dezena,
	   ceiling(day(base.data) / 15.7) as Quinzena,
	   upper(datename(month,base.data)) as Mes,
	   upper(left(datename(month,base.data),3)) as MesAbreviado,
	   month(base.data) as NumMes,
	   upper(left(datename(month,base.data),3)) +'/' + cast(year(base.Data) as char(4)) as MesAno,
	   year(base.Data) * 100 + month(base.Data) as MesanoInt,
	   datename(month,dateadd(month,case when day(base.data) > 15 then 1 else 0 end,base.data)) + '/' + cast(year(dateadd(month,case when day(base.data) > 15 then 1 else 0 end,base.data)) as char(4)) as MesPonto,
	   ceiling((month(base.data) / 2.0)) as Bimestre,
	   ceiling((month(base.data) / 3.0)) as Trimestre,
	   ceiling((month(base.data) / 6.0)) as Semestre,
	   year(base.Data) as Ano,
	   0 as Feriado,
	   0 as DiaUtil,
	   datepart(WK,base.data) as SemanaAno,
	   right('0' + cast(day(base.data) as varchar(2)),2) + '-' + UPPER(left(datename(month,base.data),1)) + lower(right(left(datename(month,base.data),3),2)) + '_' + UPPER(left(datename(WEEKDAY,base.data),1)) + lower(right(left(datename(WEEKDAY,base.data),3),2)) as PeriodoSemana	   
from base
	left join DimData as datas on base.Data= datas.Data
where datas.SkData is null
option (maxrecursion 0)

if not exists (select SkData from DimData where SkData = -1)
	begin
		insert into DimData values (-1, '1900-01-01',0,0,'Indefinido',0,0,'Indefinido','N/A',0,'Indefinido',0,'Indefinido',0,0,0,0,0,0,0,'Indefinido')
	end

end
GO
