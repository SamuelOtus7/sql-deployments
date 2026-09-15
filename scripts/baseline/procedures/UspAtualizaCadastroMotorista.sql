-- ============================================================
-- BASELINE: dbo.UspAtualizaCadastroMotorista
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspAtualizaCadastroMotorista]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UspAtualizaCadastroMotorista]

AS

BEGIN

DROP TABLE IF EXISTS #tmp_formulario

SELECT	FRM.frm_nm_formulario,
		RSP.frr_json_formulario_resposta,
		JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.nomeCompleto')							AS Nome,
		JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.rg')									AS RG,
		JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.estadoDeNascimento6')					AS Estado_Nascimento,
		JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.orgaoEmissor')							AS Orgao_Emissor,
		CASE
			WHEN ISNULL(JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.estadoCivil2'),
			JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.estadoCivil')) = 'DivorciadoA'
				THEN 'Divorciado'
			WHEN ISNULL(JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.estadoCivil2'),
			JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.estadoCivil')) = 'SeparadoA'
				THEN 'Separado'
			WHEN ISNULL(JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.estadoCivil2'),
			JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.estadoCivil')) = 'SolteiroA'
				THEN 'Solteiro'
			WHEN ISNULL(JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.estadoCivil2'),
			JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.estadoCivil')) = 'CasadoA'
				THEN 'Casado'
			ELSE ISNULL(JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.estadoCivil2'),
			JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.estadoCivil'))
		END AS EstadoCivil,
		JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.cidadeDeNascimento1')					AS Cidade_Nascimento,

		CASE
			WHEN JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.nacionalidade') = 'brasileiroA'
				THEN 'brasileiro'
			WHEN JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.nacionalidade') = 'estrangeiroA'
				THEN 'estrangeiro'
			ELSE NULL
		END																							AS Nacionalidade,
		JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.nomeDoPai')								AS Nome_Pai,
		JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.nomeDaMae')								AS Nome_Mae,
		CASE
			WHEN ISDATE(SUBSTRING(ISNULL(JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.dataDeNascimento'),
				JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.dataDeNascimento')),1,10)) = 1
				THEN CONVERT(DATE,SUBSTRING(ISNULL(JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.dataDeNascimento'),
					JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.dataDeNascimento')),1,10))
			ELSE NULL 
		END																							AS Data_Nascimento,
		ISNULL(JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.eMail1'),
			JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.email'))							AS Email,
		JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.endereco1')								AS Endereco,


		CASE
			WHEN ISNUMERIC(JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.numero')) = 1
				THEN JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.numero')
			ELSE NULL 
		END																							AS Numero,
		JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.complemento')							AS Complemento,
		JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.bairro1')								AS Bairro,
		JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.cidade')								AS Cidade,
		ISNULL(JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.cep1'),
			JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.cep'))								AS CEP,
		JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.estado1')								AS Estado,
		JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.razaoSocial')							AS Razao_Social,
		JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.enderecoEmpresarial')					AS Endereco_Empresarial,
		JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.representanteLegal')					AS Representante_Legal,
		JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.marcaVeiculo')							AS Marca_Veiculo,
		JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.modeloVeiculo')							AS Modelo_Veiculo,
		JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.corVeiculo')							AS Cor_Veiculo,
		JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.placaVeiculo')							AS Placa_Veiculo,
		JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.especieDeVeiculo')						AS Especie_Veiculo,
		JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.cidadeDoVeiculo')						AS Cidade_Veiculo,
		CASE
			WHEN ISDATE(SUBSTRING(ISNULL(JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.dataDeEmissaoCnh'),
				JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.dataDeEmissaoCnh')),1,10)) = 1
				THEN CONVERT(DATE,SUBSTRING(ISNULL(JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.dataDeEmissaoCnh'),
					JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.dataDeEmissaoCnh')),1,10))
			ELSE NULL 
		END																							AS Data_Emissao_CNH,

		CASE
			WHEN ISDATE(SUBSTRING(ISNULL(JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.dataDaPrimeiraHabilitacao'),
				JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.dataDaPrimeiraHabilitacao')),1,10)) = 1
				THEN CONVERT(DATE,SUBSTRING(ISNULL(JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.dataDaPrimeiraHabilitacao'),
					JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.dataDaPrimeiraHabilitacao')),1,10))
			ELSE NULL 
		END																							AS Data_Primeira_Habilitacao,

		CASE
			WHEN ISDATE(SUBSTRING(ISNULL(JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.dataDeValidadeCnh'),
				JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.dataDeValidadeCnh')),1,10)) = 1
				THEN CONVERT(DATE,SUBSTRING(ISNULL(JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.dataDeValidadeCnh'),
					JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.dataDeValidadeCnh')),1,10))
			ELSE NULL 
		END																							AS Data_Validade_CNH,
		JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.nomeCompletoDoProprietario')			AS Proprietario_Veiculo,
		JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.numeroWhatsapp')						AS Numero_Whatsapp,
		JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.cpf')									AS CPF,
		JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.cnpj')									AS CNPJ,

		CASE
			WHEN ISNUMERIC(JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.anoVeiculo')) = 1
				THEN JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.anoVeiculo')
			ELSE NULL
		END																							AS Ano_Veiculo,
		JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.renavam')								AS Renavam,
		JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.rntrc')									AS RNTRC,
		JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.dataAssinatura')						AS Data_Assinatura,
		JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.localAssinatura')						AS Local_Assinatura,
		JSON_VALUE(RSP.frr_json_formulario_resposta,'$.data.dataInicio')							AS Data_Inicio
INTO #tmp_formulario
FROM tb_formularios_respostas AS RSP
INNER JOIN tb_formularios	  AS FRM ON FRM.frm_cd_formulario = RSP.frr_cd_formulario
WHERE frr_ds_status = 'Aprovado'
	AND FRM.frm_nm_formulario IN ('formulario_padrao_gr','formulario_padrao')
	AND ISJSON(RSP.frr_json_formulario_resposta) > 0

DROP TABLE IF EXISTS #tmp_formulario_UPD

SELECT	CASE
			WHEN Nome = ''
				THEN NULL
			ELSE LTRIM(RTRIM(Nome))
		END												AS Nome,
		CASE
			WHEN Nome = ''
				THEN NULL
			ELSE dbo.fn_remove_acentuacao(LTRIM(RTRIM(Nome)))
		END												AS Nome_Trat,
		CASE
			WHEN RG = ''
				THEN NULL
			ELSE LTRIM(RTRIM(RG))
		END												AS RG,
		CASE
			WHEN Estado_Nascimento = ''
				THEN NULL
			ELSE LTRIM(RTRIM(Estado_Nascimento))
		END												AS Estado_Nascimento,
		CASE
			WHEN Orgao_Emissor = ''
				THEN NULL
			ELSE LTRIM(RTRIM(Orgao_Emissor))
		END												AS Orgao_Emissor,
		CASE
			WHEN EstadoCivil = ''
				THEN NULL
			ELSE LTRIM(RTRIM(EstadoCivil))
		END												AS EstadoCivil,
		CASE
			WHEN Cidade_Nascimento = ''
				THEN NULL
			ELSE LTRIM(RTRIM(Cidade_Nascimento))
		END												AS Cidade_Nascimento,
		CASE
			WHEN Nacionalidade = ''
				THEN NULL
			ELSE LTRIM(RTRIM(Nacionalidade))
		END												AS Nacionalidade,
		CASE
			WHEN Nacionalidade = 'brasileiro'
				THEN 1
			WHEN Nacionalidade = 'estrangeiro'
				THEN 2
			ELSE NULL
		END												AS Codigo_Tipo_Nacionalidade,
		CASE
			WHEN Nome_Pai = ''
				THEN NULL
			ELSE LTRIM(RTRIM(Nome_Pai))
		END												AS Nome_Pai,
		CASE
			WHEN Nome_Mae = ''
				THEN NULL
			ELSE LTRIM(RTRIM(Nome_Mae))
		END												AS Nome_Mae,
		Data_Nascimento,
		CASE
			WHEN Email = ''
				THEN NULL
			ELSE LTRIM(RTRIM(Email))
		END												AS Email,
		CASE
			WHEN Endereco = ''
				THEN NULL
			ELSE LTRIM(RTRIM(Endereco))
		END												AS Endereco,
		Numero,
		CASE
			WHEN Complemento = ''
				THEN NULL
			ELSE LTRIM(RTRIM(Complemento))
		END												AS Complemento,
		CASE
			WHEN Bairro = ''
				THEN NULL
			ELSE LTRIM(RTRIM(Bairro))
		END												AS Bairro,
		CASE
			WHEN Cidade = ''
				THEN NULL
			ELSE LTRIM(RTRIM(Cidade))
		END												AS Cidade,
		CASE
			WHEN CEP = ''
				THEN NULL
			ELSE LTRIM(RTRIM(CEP))
		END												AS CEP,
		CASE
			WHEN Estado = ''
				THEN NULL
			ELSE LTRIM(RTRIM(Estado))
		END												AS Estado,
		CASE
			WHEN Razao_Social = ''
				THEN NULL
			ELSE LTRIM(RTRIM(Razao_Social))
		END												AS Razao_Social,
		CASE
			WHEN Endereco_Empresarial = ''
				THEN NULL
			ELSE LTRIM(RTRIM(Endereco_Empresarial))
		END												AS Endereco_Empresarial,
		CASE
			WHEN Representante_Legal = ''
				THEN NULL
			ELSE LTRIM(RTRIM(Representante_Legal))
		END												AS Representante_Legal,
		CASE
			WHEN Marca_Veiculo = ''
				THEN NULL
			ELSE LTRIM(RTRIM(Marca_Veiculo))
		END												AS Marca_Veiculo,
		CASE
			WHEN Modelo_Veiculo = ''
				THEN NULL
			ELSE LTRIM(RTRIM(Modelo_Veiculo))
		END												AS Modelo_Veiculo,
		CASE
			WHEN Cor_Veiculo = ''
				THEN NULL
			ELSE LTRIM(RTRIM(Cor_Veiculo))
		END												AS Cor_Veiculo,
		CASE
			WHEN Placa_Veiculo = ''
				THEN NULL
			ELSE LTRIM(RTRIM(Placa_Veiculo))
		END												AS Placa_Veiculo,
		CASE
			WHEN Especie_Veiculo = ''
				THEN NULL
			ELSE LTRIM(RTRIM(Especie_Veiculo))
		END												AS Especie_Veiculo,
		CASE
			WHEN Cidade_Veiculo = ''
				THEN NULL
			ELSE LTRIM(RTRIM(Cidade_Veiculo))
		END												AS Cidade_Veiculo,
		Data_Emissao_CNH,
		Data_Primeira_Habilitacao,
		Data_Validade_CNH,
		CASE
			WHEN Proprietario_Veiculo = ''
				THEN NULL
			ELSE LTRIM(RTRIM(Proprietario_Veiculo))
		END												AS Proprietario_Veiculo,
		CASE
			WHEN Numero_Whatsapp = ''
				THEN NULL
			ELSE LTRIM(RTRIM(Numero_Whatsapp))
		END												AS Numero_Whatsapp,
		CASE
			WHEN CPF = ''
				THEN NULL
			ELSE LTRIM(RTRIM(CPF))
		END												AS CPF,
		CASE
			WHEN CNPJ = ''
				THEN NULL
			ELSE LTRIM(RTRIM(CNPJ))
		END												AS CNPJ,
		Ano_Veiculo,
		CASE
			WHEN Renavam = ''
				OR Renavam = '0'
				THEN NULL
			ELSE LTRIM(RTRIM(Renavam))
		END												AS Renavam
INTO #tmp_formulario_UPD
FROM #tmp_formulario
WHERE LTRIM(RTRIM(Nome)) <> ''
	AND Nome IS NOT NULL

UPDATE MOT
SET mot_cpf = UPD.CPF
FROM tb_motorista			   AS MOT
INNER JOIN #tmp_formulario_UPD AS UPD ON UPD.Nome = MOT.mot_nm_motorista
								OR UPD.Nome_Trat  = MOT.mot_nm_motorista
WHERE UPD.CPF IS NOT NULL

UPDATE MOT
SET mot_dt_nascimento = UPD.Data_Nascimento
FROM tb_motorista			   AS MOT
INNER JOIN #tmp_formulario_UPD AS UPD ON UPD.Nome = MOT.mot_nm_motorista
								OR UPD.Nome_Trat  = MOT.mot_nm_motorista
WHERE UPD.Data_Nascimento IS NOT NULL

UPDATE MOT
SET mot_end_nm_residencia = UPD.Endereco
FROM tb_motorista			   AS MOT
INNER JOIN #tmp_formulario_UPD AS UPD ON UPD.Nome = MOT.mot_nm_motorista
								OR UPD.Nome_Trat  = MOT.mot_nm_motorista
WHERE UPD.Endereco IS NOT NULL

UPDATE MOT
SET mot_end_vl_cep = UPD.CEP
FROM tb_motorista			   AS MOT
INNER JOIN #tmp_formulario_UPD AS UPD ON UPD.Nome = MOT.mot_nm_motorista
								OR UPD.Nome_Trat  = MOT.mot_nm_motorista
WHERE UPD.CEP IS NOT NULL

UPDATE MOT
SET mot_end_ds_rua = UPD.Endereco
FROM tb_motorista			   AS MOT
INNER JOIN #tmp_formulario_UPD AS UPD ON UPD.Nome = MOT.mot_nm_motorista
								OR UPD.Nome_Trat  = MOT.mot_nm_motorista
WHERE UPD.Endereco IS NOT NULL

UPDATE MOT
SET mot_end_vl_numero = UPD.Numero
FROM tb_motorista			   AS MOT
INNER JOIN #tmp_formulario_UPD AS UPD ON UPD.Nome = MOT.mot_nm_motorista
								OR UPD.Nome_Trat  = MOT.mot_nm_motorista
WHERE UPD.Numero IS NOT NULL

UPDATE MOT
SET mot_end_ds_complemento = UPD.Complemento
FROM tb_motorista			   AS MOT
INNER JOIN #tmp_formulario_UPD AS UPD ON UPD.Nome = MOT.mot_nm_motorista
								OR UPD.Nome_Trat  = MOT.mot_nm_motorista
WHERE UPD.Complemento IS NOT NULL

UPDATE MOT
SET mot_end_nm_bairro = UPD.Bairro
FROM tb_motorista			   AS MOT
INNER JOIN #tmp_formulario_UPD AS UPD ON UPD.Nome = MOT.mot_nm_motorista
								OR UPD.Nome_Trat  = MOT.mot_nm_motorista
WHERE UPD.Bairro IS NOT NULL

UPDATE MOT
SET mot_cnt_vl_telefone = UPD.Numero_Whatsapp
FROM tb_motorista			   AS MOT
INNER JOIN #tmp_formulario_UPD AS UPD ON UPD.Nome = MOT.mot_nm_motorista
								OR UPD.Nome_Trat  = MOT.mot_nm_motorista
WHERE UPD.Numero_Whatsapp IS NOT NULL

UPDATE MOT
SET mot_cnt_vl_email = UPD.Email
FROM tb_motorista			   AS MOT
INNER JOIN #tmp_formulario_UPD AS UPD ON UPD.Nome = MOT.mot_nm_motorista
								OR UPD.Nome_Trat  = MOT.mot_nm_motorista
WHERE UPD.Email IS NOT NULL

UPDATE MOT
SET mot_gr_nm_mae = UPD.Nome_Mae
FROM tb_motorista			   AS MOT
INNER JOIN #tmp_formulario_UPD AS UPD ON UPD.Nome = MOT.mot_nm_motorista
								OR UPD.Nome_Trat  = MOT.mot_nm_motorista
WHERE UPD.Nome_Mae IS NOT NULL

UPDATE MOT
SET mot_gr_nm_pai = UPD.Nome_Pai
FROM tb_motorista			   AS MOT
INNER JOIN #tmp_formulario_UPD AS UPD ON UPD.Nome = MOT.mot_nm_motorista
								OR UPD.Nome_Trat  = MOT.mot_nm_motorista
WHERE UPD.Nome_Pai IS NOT NULL

UPDATE MOT
SET mot_gr_nm_tipo_nacionalidade = UPD.Codigo_Tipo_Nacionalidade
FROM tb_motorista			   AS MOT
INNER JOIN #tmp_formulario_UPD AS UPD ON UPD.Nome = MOT.mot_nm_motorista
								OR UPD.Nome_Trat  = MOT.mot_nm_motorista
WHERE UPD.Codigo_Tipo_Nacionalidade IS NOT NULL

UPDATE MOT
SET mot_gr_vl_rg_motorista = UPD.RG
FROM tb_motorista			   AS MOT
INNER JOIN #tmp_formulario_UPD AS UPD ON UPD.Nome = MOT.mot_nm_motorista
								OR UPD.Nome_Trat  = MOT.mot_nm_motorista
WHERE UPD.RG IS NOT NULL

UPDATE MOT
SET mot_gr_vl_cnh_motorista = UPD.Numero_CNH
FROM tb_motorista			   AS MOT
INNER JOIN #tmp_formulario_UPD AS UPD ON UPD.Nome = MOT.mot_nm_motorista
								OR UPD.Nome_Trat  = MOT.mot_nm_motorista
WHERE UPD.Numero_CNH IS NOT NULL

UPDATE MOT
SET mot_gr_dt_primeira_cnh_motorista = UPD.Data_Primeira_Habilitacao
FROM tb_motorista			   AS MOT
INNER JOIN #tmp_formulario_UPD AS UPD ON UPD.Nome = MOT.mot_nm_motorista
								OR UPD.Nome_Trat  = MOT.mot_nm_motorista
WHERE UPD.Data_Primeira_Habilitacao IS NOT NULL

UPDATE MOT
SET mot_gr_dt_vencimento_cnh_motorista = UPD.Data_Validade_CNH
FROM tb_motorista			   AS MOT
INNER JOIN #tmp_formulario_UPD AS UPD ON UPD.Nome = MOT.mot_nm_motorista
								OR UPD.Nome_Trat  = MOT.mot_nm_motorista
WHERE UPD.Data_Validade_CNH IS NOT NULL

UPDATE MOT
SET mot_cd_vehicle_year = UPD.Ano_Veiculo
FROM tb_motorista			   AS MOT
INNER JOIN #tmp_formulario_UPD AS UPD ON UPD.Nome = MOT.mot_nm_motorista
								OR UPD.Nome_Trat  = MOT.mot_nm_motorista
WHERE UPD.Ano_Veiculo IS NOT NULL

UPDATE MOT
SET mot_ds_estado_civil = UPD.Estado_Civil
FROM tb_motorista			   AS MOT
INNER JOIN #tmp_formulario_UPD AS UPD ON UPD.Nome = MOT.mot_nm_motorista
								OR UPD.Nome_Trat  = MOT.mot_nm_motorista
WHERE UPD.Estado_Civil IS NOT NULL

UPDATE MOT
SET mot_ds_nacionalidade = UPD.Nacionalidade
FROM tb_motorista			   AS MOT
INNER JOIN #tmp_formulario_UPD AS UPD ON UPD.Nome = MOT.mot_nm_motorista
								OR UPD.Nome_Trat  = MOT.mot_nm_motorista
WHERE UPD.Nacionalidade IS NOT NULL

UPDATE MOT
SET mot_ds_orgao_emissor_rg = UPD.Orgao_Emissor
FROM tb_motorista			   AS MOT
INNER JOIN #tmp_formulario_UPD AS UPD ON UPD.Nome = MOT.mot_nm_motorista
								OR UPD.Nome_Trat  = MOT.mot_nm_motorista
WHERE UPD.Orgao_Emissor IS NOT NULL

END
GO
