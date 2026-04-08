<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
    xmlns:xades="http://uri.etsi.org/01903/v1.3.2#"
    xmlns:ppZP="http://crd.gov.pl/xml/schematy/ppzp/"
    xmlns:os="http://crd.gov.pl/xml/schematy/osoba/2009/03/06/">

	<xsl:output method="html" encoding="UTF-8" indent="yes"/>

	<xsl:template name="pad">
		<xsl:param name="n"/>
		<xsl:choose>
			<xsl:when test="number($n) &lt; 10">
				<xsl:text>0</xsl:text>
				<xsl:value-of select="number($n)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="number($n)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- formatowanie epoch (XSLT 1.0) jako milisekundy -->
	<xsl:template name="formatEpochMs">
		<xsl:param name="raw"/>
		<xsl:variable name="s" select="normalize-space(string($raw))"/>
		<xsl:choose>

			<xsl:when test="string-length($s) &gt; 0 and translate($s,'0123456789','') = ''">
				<xsl:variable name="num" select="number($s)"/>
				<xsl:variable name="sec" select="floor($num div 1000)"/>
				<xsl:variable name="days" select="floor($sec div 86400)"/>
				<xsl:variable name="secsOfDay" select="$sec mod 86400"/>
				<xsl:variable name="hour" select="floor($secsOfDay div 3600)"/>
				<xsl:variable name="minute" select="floor(($secsOfDay mod 3600) div 60)"/>

				<xsl:variable name="J" select="$days + 2440588"/>
				<xsl:variable name="l" select="$J + 68569"/>
				<xsl:variable name="n" select="floor(4 * $l div 146097)"/>
				<xsl:variable name="l2" select="$l - floor((146097 * $n + 3) div 4)"/>
				<xsl:variable name="i" select="floor(4000 * ($l2 + 1) div 1461001)"/>
				<xsl:variable name="l3" select="$l2 - floor(1461 * $i div 4) + 31"/>
				<xsl:variable name="j" select="floor(80 * $l3 div 2447)"/>
				<xsl:variable name="day" select="$l3 - floor(2447 * $j div 80)"/>
				<xsl:variable name="l4" select="floor($j div 11)"/>
				<xsl:variable name="month" select="$j + 2 - 12 * $l4"/>
				<xsl:variable name="year" select="100 * ($n - 49) + $i + $l4"/>

				<xsl:call-template name="pad">
					<xsl:with-param name="n" select="$day"/>
				</xsl:call-template>
				<xsl:text>.</xsl:text>
				<xsl:call-template name="pad">
					<xsl:with-param name="n" select="$month"/>
				</xsl:call-template>
				<xsl:text>.</xsl:text>
				<xsl:value-of select="$year"/>
				<xsl:text> </xsl:text>
				<xsl:call-template name="pad">
					<xsl:with-param name="n" select="$hour"/>
				</xsl:call-template>
				<xsl:text>:</xsl:text>
				<xsl:call-template name="pad">
					<xsl:with-param name="n" select="$minute"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$s"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="/WniosekUkrDTO">
		<html>
			<head>
				<meta charset="UTF-8"/>
				<title>
					Wniosek nr <xsl:value-of select="czynwnDTO/idczynwn"/>
				</title>
				<style>

					@page { size: A4; margin: 10mm; }
					body {
					font-family: "Helvetica Neue", Arial, Helvetica, sans-serif;
					color: #111;
					background: #fff;
					margin: 0;
					padding: 10mm;
					font-size: 13px;
					line-height: 1.45;
					box-sizing: border-box;
					}

					.h1 {
					margin: 0;
					font-size: 18px;
					letter-spacing: 0.5px;
					font-weight: 700;
					text-transform: uppercase;
					}
					.header {
					margin-bottom: 12px;
					padding-bottom: 8px;
					}

					.header-title {
					margin-bottom: 12px;
					}

					.header-info {
					display: block;
					}

					.header-line {
					margin: 3px 0;
					font-size: 14px;
					line-height: 1.35;
					}

					.header-label {
					font-weight: 500;
					color: #444;
					}

					.header-value {
					font-weight: 700;
					color: #111;
					}


					h2.section {
					font-size: 13px;
					margin: 20px 0 8px;
					padding-top: 6px;
					border-top: 1px solid #666;
					color: #000;
					font-weight: 700;
					text-transform: uppercase;
					}

					.data-table {
					width: 100%;
					border-collapse: collapse;
					margin-bottom: 6px;
					}
					.data-table td {
					padding: 6px 10px;
					vertical-align: top;
					}
					.data-table td.label {
					width: 260px;
					color: #444;
					font-weight: 600;
					}
					.data-table td.value {
					padding-right: 0;
					}

					.not-applicable { color: #999; font-style: italic; }

					.consent-section {
					padding: 2px 20px;
					}
					.consent-item {
					display: table;
					width: 100%;
					table-layout: fixed;
					margin: 6px 0;
					}
					.consent-item .chk {
					display: table-cell;
					width: 28px;
					vertical-align: top;
					padding-right: 8px;
					}
					.consent-item .txt {
					display: table-cell;
					vertical-align: top;
					white-space: normal;
					color: #111;
					}
					.checkbox-marker {
					display: inline-block;
					width: 18px;
					height: 18px;
					border: 1px solid #333;
					text-align: center;
					line-height: 16px;
					}

					.signature-block {
					margin-top: 18px;
					display: flex;
					gap: 24px;
					justify-content: space-between;
					}
					.signature {
					width: 48%;
					min-height: 80px;
					border-top: 1px solid #333;
					padding-top: 8px;
					font-size: 13px;
					color: #333;
					}

					.signature-info { font-size: 13px; color: #555; margin-top: 8px; }

					.clear { clear: both; }
				</style>
			</head>
			<body>

				<div class="header">
					<div class="header-title">
						<h1 class="h1">
							WNIOSEK O WYDANIE KARTY POBYTU OBYWATELOWI UKRAINY W PRZYPADKACH, O KTÓRYCH MOWA
							W ART. 42C I ART. 42D USTAWY Z DNIA 12 MARCA 2022 R. O POMOCY OBYWATELOM UKRAINY
							W ZWIĄZKU Z KONFLIKTEM ZBROJNYM NA TERYTORIUM TEGO PAŃSTWA
						</h1>
					</div>

					<div class="header-info">
						<div class="header-line">
							<span class="header-label">Nazwa organu, do którego jest składany wniosek:</span>
							<span class="header-value">
								<xsl:value-of select="czynwnDTO/slorganjednostkaprzyj/nazwa"/>
							</span>
						</div>

						<div class="header-line">
							<span class="header-label">Nr wniosku:</span>
							<span class="header-value">
								<xsl:value-of select="czynwnDTO/idczynwn"/>
							</span>
						</div>

						<div class="header-line">
							<span class="header-label">Data złożenia wniosku:</span>
							<span class="header-value">
								<xsl:if test="czynwnDTO/datawpisu">
									<xsl:call-template name="formatEpochMs">
										<xsl:with-param name="raw" select="normalize-space(czynwnDTO/datawpisu)"/>
									</xsl:call-template>
								</xsl:if>
							</span>
						</div>
					</div>
				</div>

				<h2 class="section">A. DANE OSOBOWE WNIOSKODAWCY</h2>
				<table class="data-table">
					<tr>
						<td class="label">Nazwisko:</td>
						<td class="value">
							<xsl:value-of select="tozsamoscDTO/nazwisko"/>
						</td>
					</tr>
					<tr>
						<td class="label">Nazwiska poprzednie:</td>
						<td class="value">
							<xsl:choose>
								<xsl:when test="tozsamoscDTO/nazwiskopopinneDTOList/nazwiskopopinneDTOList/imienazwisko">
									<xsl:value-of select="tozsamoscDTO/nazwiskopopinneDTOList/nazwiskopopinneDTOList/imienazwisko"/>
								</xsl:when>
								<xsl:when test="checkboxes/nazwiskopopinneDTOList = 'true'">
									<span class="not-applicable">brak</span>
								</xsl:when>
								<xsl:otherwise>
									<span class="not-applicable">nie podano</span>
								</xsl:otherwise>
							</xsl:choose>
						</td>
					</tr>

					<tr>
						<td class="label">Nazwisko rodowe:</td>
						<td class="value">
							<xsl:choose>
								<xsl:when test="string-length(normalize-space(tozsamoscDTO/nazwiskorod)) &gt; 0">
									<xsl:value-of select="tozsamoscDTO/nazwiskorod"/>
								</xsl:when>
								<xsl:when test="checkboxes/nazwiskorod = 'true'">
									<span class="not-applicable">brak</span>
								</xsl:when>
								<xsl:otherwise>
									<span class="not-applicable">nie podano</span>
								</xsl:otherwise>
							</xsl:choose>
						</td>
					</tr>

					<tr>
						<td class="label">Imię (imiona):</td>
						<td class="value">
							<xsl:value-of select="tozsamoscDTO/imie"/>
						</td>
					</tr>

					<tr>
						<td class="label">Imię (imiona) poprzednie:</td>
						<td class="value">
							<xsl:choose>
								<xsl:when test="string-length(normalize-space(tozsamoscDTO/imiepop)) &gt; 0">
									<xsl:value-of select="tozsamoscDTO/imiepop"/>
								</xsl:when>
								<xsl:when test="checkboxes/imiepopinneDTOList = 'true'">
									<span class="not-applicable">brak</span>
								</xsl:when>
								<xsl:otherwise>
									<span class="not-applicable">nie podano</span>
								</xsl:otherwise>
							</xsl:choose>
						</td>
					</tr>

					<tr>
						<td class="label">Imię ojca:</td>
						<td class="value">
							<xsl:choose>
								<xsl:when test="string-length(normalize-space(tozsamoscDTO/imieojca)) &gt; 0">
									<xsl:value-of select="tozsamoscDTO/imieojca"/>
								</xsl:when>
								<xsl:otherwise>
									<span class="not-applicable">brak</span>
								</xsl:otherwise>
							</xsl:choose>
						</td>
					</tr>

					<tr>
						<td class="label">Imię matki:</td>
						<td class="value">
							<xsl:choose>
								<xsl:when test="string-length(normalize-space(tozsamoscDTO/imiematki)) &gt; 0">
									<xsl:value-of select="tozsamoscDTO/imiematki"/>
								</xsl:when>
								<xsl:otherwise>
									<span class="not-applicable">brak</span>
								</xsl:otherwise>
							</xsl:choose>
						</td>
					</tr>

					<tr>
						<td class="label">Data urodzenia:</td>
						<td class="value">
							<xsl:value-of select="tozsamoscDTO/dataur"/>
						</td>
					</tr>

					<tr>
						<td class="label">Płeć:</td>
						<td class="value">
							<xsl:value-of select="tozsamoscDTO/slplec/nazwa"/>
						</td>
					</tr>

					<tr>
						<td class="label">Miejsce urodzenia:</td>
						<td class="value">
							<xsl:choose>
								<xsl:when test="string-length(normalize-space(tozsamoscDTO/miejsceur)) &gt; 0">
									<xsl:value-of select="normalize-space(tozsamoscDTO/miejsceur)"/>
								</xsl:when>
								<xsl:otherwise>
									<span class="not-applicable">nie podano</span>
								</xsl:otherwise>
							</xsl:choose>
						</td>
					</tr>
					<tr>
						<td class="label">Kraj urodzenia:</td>
						<td class="value">
							<xsl:choose>
								<xsl:when test="string-length(normalize-space(tozsamoscDTO/slkrajurodzenia/nazwa)) &gt; 0">
									<xsl:value-of select="normalize-space(tozsamoscDTO/slkrajurodzenia/nazwa)"/>
								</xsl:when>
								<xsl:otherwise>
									<span class="not-applicable">nie podano</span>
								</xsl:otherwise>
							</xsl:choose>
						</td>
					</tr>

					<tr>
						<td class="label">Narodowość:</td>
						<td class="value">
							<xsl:value-of select="tozsamoscDTO/slnarodowosc/nazwa"/>
						</td>
					</tr>

					<tr>
						<td class="label">Obywatelstwo (obywatelstwa):</td>
						<td class="value">
							<xsl:for-each select="tozsamoscDTO/slobywatelstwoList/slobywatelstwoList">
								<xsl:value-of select="nazwa"/>
								<xsl:if test="position() != last()">
									<xsl:text>, </xsl:text>
								</xsl:if>
							</xsl:for-each>
						</td>
					</tr>

					<tr>
						<td class="label">Stan cywilny:</td>
						<td class="value">
							<xsl:value-of select="tozsamoscDTO/slstancywilny/nazwa"/>
						</td>
					</tr>

					<tr>
						<td class="label">Rysopis - Wzrost:</td>
						<td class="value">
							<xsl:choose>
								<xsl:when test="rysopisDTO/wzrost != ''">
									<xsl:value-of select="rysopisDTO/wzrost"/> cm
								</xsl:when>
								<xsl:otherwise>
									<span class="not-applicable">nie podano</span>
								</xsl:otherwise>
							</xsl:choose>
						</td>
					</tr>

					<tr>
						<td class="label">Rysopis - Kolor oczu:</td>
						<td class="value">
							<xsl:choose>
								<xsl:when test="rysopisDTO/slkoloroczu/nazwa">
									<xsl:value-of select="rysopisDTO/slkoloroczu/nazwa"/>
								</xsl:when>
								<xsl:otherwise>
									<span class="not-applicable">nie podano</span>
								</xsl:otherwise>
							</xsl:choose>
						</td>
					</tr>

					<tr>
						<td class="label">Rysopis - Znaki szczególne:</td>
						<td class="value">
							<xsl:choose>
								<xsl:when test="rysopisDTO/slznakszczegolnyList/slznakszczegolnyList">
									<xsl:for-each select="rysopisDTO/slznakszczegolnyList/slznakszczegolnyList">
										<xsl:value-of select="nazwa"/>
										<xsl:if test="position() != last()">
											<xsl:text>; </xsl:text>
										</xsl:if>
									</xsl:for-each>
								</xsl:when>
								<xsl:otherwise>
									<span class="not-applicable">brak</span>
								</xsl:otherwise>
							</xsl:choose>
						</td>
					</tr>

					<tr>
						<td class="label">Numer PESEL:</td>
						<td class="value">
							<xsl:value-of select="tozsamoscDTO/pesel"/>
						</td>
					</tr>

					<tr>
						<td class="label">Numer telefonu do kontaktu:</td>
						<td class="value">
							<xsl:choose>
								<xsl:when test="tozsamoscDTO/telefon != ''">
									<xsl:if test="tozsamoscDTO/slmoskodkraju/kod">
										<xsl:value-of select="tozsamoscDTO/slmoskodkraju/kod"/>
										<xsl:text> </xsl:text>
									</xsl:if>
									<xsl:value-of select="tozsamoscDTO/telefon"/>
								</xsl:when>
								<xsl:otherwise>
									<span class="not-applicable">nie podano</span>
								</xsl:otherwise>
							</xsl:choose>
						</td>
					</tr>

					<tr>
						<td class="label">Adres email:</td>
						<td class="value">
							<xsl:choose>
								<xsl:when test="tozsamoscDTO/email != ''">
									<xsl:value-of select="tozsamoscDTO/email"/>
								</xsl:when>
								<xsl:otherwise>
									<span class="not-applicable">nie podano</span>
								</xsl:otherwise>
							</xsl:choose>
						</td>
					</tr>

					<xsl:if test="biometriaDTO/foto">
						<tr>
							<td class="label">Fotografia:</td>
							<td class="value photo">
								<img src="data:image/jpeg;base64,{biometriaDTO/foto}" alt="Zdjęcie" style="width:200px;border:1px solid #ccc"/>
							</td>
						</tr>
					</xsl:if>
				</table>

				<h2 class="section">B. DOKUMENT PODRÓŻY WNIOSKODAWCY</h2>
				<table class="data-table">
					<tr>
						<td class="label">Typ dokumentu:</td>
						<td class="value">
							<xsl:value-of select="dokpodrozyDTO/sldok/nazwa"/>
						</td>
					</tr>
					<tr>
						<td class="label">Seria:</td>
						<td class="value">
							<xsl:choose>
								<xsl:when test="string-length(normalize-space(dokpodrozyDTO/seria)) &gt; 0">
									<xsl:value-of select="dokpodrozyDTO/seria"/>
								</xsl:when>
								<xsl:otherwise>
									<span class="not-applicable">brak</span>
								</xsl:otherwise>
							</xsl:choose>
						</td>
					</tr>
					<tr>
						<td class="label">Numer:</td>
						<td class="value">
							<xsl:value-of select="dokpodrozyDTO/numer"/>
						</td>
					</tr>
					<tr>
						<td class="label">Data wydania:</td>
						<td class="value">
							<xsl:value-of select="dokpodrozyDTO/datawydania"/>
						</td>
					</tr>
					<tr>
						<td class="label">Data upływu ważności:</td>
						<td class="value">
							<xsl:value-of select="dokpodrozyDTO/waznydo"/>
						</td>
					</tr>
					<tr>
						<td class="label">Organ wydający:</td>
						<td class="value">
							<xsl:value-of select="dokpodrozyDTO/wydanyprzez"/>
						</td>
					</tr>
					<tr>
						<td class="label">Liczba innych osób wpisanych do dokumentu podróży:</td>
						<td class="value">
							<xsl:choose>
								<xsl:when test="dokpodrozyDTO/liczbawpisosob != ''">
									<xsl:value-of select="dokpodrozyDTO/liczbawpisosob"/>
								</xsl:when>
								<xsl:when test="checkboxes/liczbawpisosob = 'true'">
									<span class="not-applicable">brak</span>
								</xsl:when>
								<xsl:otherwise>
									<span class="not-applicable">nie podano</span>
								</xsl:otherwise>
							</xsl:choose>
						</td>
					</tr>
				</table>

				<h2 class="section">C. MIEJSCE POBYTU WNIOSKODAWCY NA TERYTORIUM RP</h2>
				<table class="data-table">
					<tr>
						<td class="label">Województwo:</td>
						<td class="value">
							<xsl:value-of select="adreskrajDTO/wojewodztwoDTO/nazwa"/>
						</td>
					</tr>
					<tr>
						<td class="label">Powiat:</td>
						<td class="value">
							<xsl:value-of select="adreskrajDTO/powiatDTO/nazwa"/>
						</td>
					</tr>
					<tr>
						<td class="label">Gmina:</td>
						<td class="value">
							<xsl:value-of select="adreskrajDTO/gminaDTO/nazwa"/>
						</td>
					</tr>
					<tr>
						<td class="label">Miejscowość:</td>
						<td class="value">
							<xsl:value-of select="adreskrajDTO/miejscowoscDTO/nazwa"/>
						</td>
					</tr>
					<tr>
						<td class="label">Ulica:</td>
						<td class="value">
							<xsl:choose>
								<xsl:when test="string-length(normalize-space(adreskrajDTO/ulicaDTO/nazwa)) &gt; 0">
									<xsl:if test="string-length(normalize-space(adreskrajDTO/ulicaDTO/rodzaj)) &gt; 0">
										<xsl:value-of select="normalize-space(adreskrajDTO/ulicaDTO/rodzaj)"/>
										<xsl:text> </xsl:text>
									</xsl:if>
									<xsl:value-of select="normalize-space(adreskrajDTO/ulicaDTO/nazwa)"/>
								</xsl:when>
								<xsl:when test="string-length(normalize-space(adreskrajDTO/ulicainna)) &gt; 0">
									<xsl:value-of select="normalize-space(adreskrajDTO/ulicainna)"/>
								</xsl:when>
								<xsl:otherwise>
									<span class="not-applicable">nie podano</span>
								</xsl:otherwise>
							</xsl:choose>
						</td>
					</tr>
					<tr>
						<td class="label">Numer domu:</td>
						<td class="value">
							<xsl:value-of select="adreskrajDTO/nrdomu"/>
						</td>
					</tr>
					<tr>
						<td class="label">Numer mieszkania:</td>
						<td class="value">
							<xsl:choose>
								<xsl:when test="adreskrajDTO/nrmieszkania != ''">
									<xsl:value-of select="adreskrajDTO/nrmieszkania"/>
								</xsl:when>
								<xsl:when test="checkboxes/miejscepobytuNrmieszkania = 'true'">
									<span class="not-applicable">brak</span>
								</xsl:when>
								<xsl:otherwise>
									<span class="not-applicable">nie podano</span>
								</xsl:otherwise>
							</xsl:choose>
						</td>
					</tr>
					<tr>
						<td class="label">Kod pocztowy:</td>
						<td class="value">
							<xsl:value-of select="adreskrajDTO/kodpocztowy"/>
						</td>
					</tr>
				</table>

				<h2 class="section">
					D. INFORMACJE O KARALNOŚCI, O PROWADZONYCH PRZECIWKO WNIOSKODAWCY
					POSTĘPOWANIACH KARNYCH I POSTĘPOWANIACH W SPRAWACH O WYKROCZENIA ORAZ O
					WYDANYCH W STOSUNKU DO NIEGO ORZECZENIACH W POSTĘPOWANIU SĄDOWYM LUB
					ADMINISTRACYJNYM
				</h2>
				<xsl:choose>
					<xsl:when test="karalnoscDTOList/karalnoscDTOList">
						<table class="data-table">

							<tr>
								<td class="label">I. Czy był(-a) Pan(-i) karany(-na) sądownie na terytorium RP?</td>
								<td class="value">
									<xsl:choose>
										<xsl:when test="karalnoscDTOList/karalnoscDTOList[karasadowa = 'T']">
											<xsl:text>Tak, kiedy, za jaki czyn, jaki zapadł wyrok i czy został wykonany?</xsl:text>
											<table style="border-collapse:collapse; margin-top:6px; width:100%;">
												<thead>
													<tr>
														<th style="border:1px solid #bbb; padding:4px 8px; text-align:left; font-weight:500;">Kiedy</th>
														<th style="border:1px solid #bbb; padding:4px 8px; text-align:left; font-weight:500;">Za jaki czyn</th>
														<th style="border:1px solid #bbb; padding:4px 8px; text-align:left; font-weight:500;">Wyrok</th>
														<th style="border:1px solid #bbb; padding:4px 8px; text-align:left; font-weight:500;">Wyrok wykonany</th>
													</tr>
												</thead>
												<tbody>
													<xsl:for-each select="karalnoscDTOList/karalnoscDTOList[karasadowa = 'T']">
														<tr>
															<td style="border:1px solid #bbb; padding:4px 8px;">
																<xsl:value-of select="karasadowadata"/>
															</td>
															<td style="border:1px solid #bbb; padding:4px 8px;">
																<xsl:value-of select="karasadowaczyn"/>
															</td>
															<td style="border:1px solid #bbb; padding:4px 8px;">
																<xsl:value-of select="karasadowawyrok"/>
															</td>
															<td style="border:1px solid #bbb; padding:4px 8px;">
																<xsl:choose>
																	<xsl:when test="karasadowawykonwyroku = 'T'">Tak</xsl:when>
																	<xsl:when test="karasadowawykonwyroku = 'N'">Nie</xsl:when>
																	<xsl:otherwise>
																		<span class="not-applicable">nie podano</span>
																	</xsl:otherwise>
																</xsl:choose>
															</td>
														</tr>
													</xsl:for-each>
												</tbody>
											</table>
										</xsl:when>
										<xsl:otherwise>Nie</xsl:otherwise>
									</xsl:choose>
								</td>
							</tr>

							<tr>
								<td class="label">II. Czy toczy się przeciwko Panu(-i) postępowanie karne lub postępowanie w sprawach o wykroczenia na terytorium RP?</td>
								<td class="value">
									<xsl:choose>
										<xsl:when test="karalnoscDTOList/karalnoscDTOList[czypostepowanie = 'T']">
											<xsl:text>Tak, </xsl:text>
											<xsl:variable name="postepowaniaUnikalne">
												<xsl:for-each select="karalnoscDTOList/karalnoscDTOList[czypostepowanie = 'T' and string-length(normalize-space(postepowaniejakie)) &gt; 0]">
													<xsl:variable name="current" select="normalize-space(postepowaniejakie)"/>
													<xsl:variable name="pos" select="position()"/>
													<xsl:if test="not(preceding-sibling::karalnoscDTOList[normalize-space(postepowaniejakie) = $current])">
														<xsl:value-of select="$current"/>
														<xsl:text>|</xsl:text>
													</xsl:if>
												</xsl:for-each>
											</xsl:variable>
											<xsl:if test="string-length(normalize-space($postepowaniaUnikalne)) &gt; 0">
												<xsl:text>jakie? </xsl:text>
												<xsl:for-each select="karalnoscDTOList/karalnoscDTOList[czypostepowanie = 'T' and string-length(normalize-space(postepowaniejakie)) &gt; 0]">
													<xsl:variable name="current" select="normalize-space(postepowaniejakie)"/>
													<xsl:if test="not(preceding-sibling::karalnoscDTOList[normalize-space(postepowaniejakie) = $current])">
														<xsl:if test="position() &gt; 1">
															<xsl:text>, </xsl:text>
														</xsl:if>
														<xsl:value-of select="$current"/>
													</xsl:if>
												</xsl:for-each>
											</xsl:if>
										</xsl:when>
										<xsl:otherwise>Nie</xsl:otherwise>
									</xsl:choose>
								</td>
							</tr>

							<tr>
								<td class="label">III. Czy ciążą na Panu(-ni) zobowiązania wynikające z orzeczeń sądowych, postanowień i decyzji administracyjnych?</td>
								<td class="value">
									<xsl:choose>
										<xsl:when test="karalnoscDTOList/karalnoscDTOList[zobowiazania = 'T']">
											<xsl:text>Tak, </xsl:text>
											<xsl:for-each select="karalnoscDTOList/karalnoscDTOList[zobowiazania = 'T' and string-length(normalize-space(zobowiazaniajakie)) &gt; 0]">
												<xsl:variable name="current" select="normalize-space(zobowiazaniajakie)"/>
												<xsl:if test="not(preceding-sibling::karalnoscDTOList[normalize-space(zobowiazaniajakie) = $current])">
													<xsl:text>jakie? </xsl:text>
													<xsl:value-of select="$current"/>
												</xsl:if>
											</xsl:for-each>
										</xsl:when>
										<xsl:otherwise>Nie</xsl:otherwise>
									</xsl:choose>
								</td>
							</tr>

						</table>
					</xsl:when>
					<xsl:otherwise>
						<p class="not-applicable">Brak danych</p>
					</xsl:otherwise>
				</xsl:choose>

				<h2 class="section">E. Załączniki do wniosku</h2>
				<xsl:choose>
					<xsl:when test="wnioseklistazalacznikowDTOList/wnioseklistazalacznikowDTOList">
						<ul class="attachments">
							<xsl:for-each select="wnioseklistazalacznikowDTOList/wnioseklistazalacznikowDTOList">
								<li>
									<xsl:value-of select="nazwa"/>
								</li>
							</xsl:for-each>
						</ul>
					</xsl:when>
					<xsl:otherwise>
						<p class="not-applicable">Brak załączników</p>
					</xsl:otherwise>
				</xsl:choose>

				<h2 class="section">F. Oświadczenie</h2>
				<div class="consent-section">

					<xsl:if test="wniosekzgodyDTO/pouczenie">
						<div class="consent-item">
							<div class="chk">
								<span class="checkbox-marker">
									<xsl:if test="wniosekzgodyDTO/pouczenie = 'T'">✓</xsl:if>
								</span>
							</div>
							<div class="txt">Potwierdzam zapoznanie się z pouczeniem.</div>
						</div>
					</xsl:if>
					<div class="consent-item">
						<div class="chk">
							<span class="checkbox-marker">
								<xsl:if test="ds:Signature">✓</xsl:if>
							</span>
						</div>
						<div class="txt">Oświadczam, że dane zawarte we wniosku są prawdziwe.</div>
					</div>

					<div class="consent-item">
						<div class="chk">
							<span class="checkbox-marker">
								<xsl:if test="ds:Signature">✓</xsl:if>
							</span>
						</div>
						<div class="txt">Jestem świadomy odpowiedzialności karnej za złożenie fałszywego oświadczenia.</div>
					</div>
				</div>

				<xsl:if test="ds:Signature">
					<h2 class="section">Podpis elektroniczny</h2>
					<div class="signature-info">
						<xsl:variable name="signingTime" select="ds:Signature/ds:Object/xades:QualifyingProperties/xades:SignedProperties/xades:SignedSignatureProperties/xades:SigningTime"/>
						<xsl:if test="$signingTime">
							<strong>Data podpisu:</strong>
							<br/>
							<xsl:value-of select="substring($signingTime, 1, 10)"/>
							<xsl:text> </xsl:text>
							<xsl:value-of select="substring($signingTime, 12, 5)"/>
							<br/>
						</xsl:if>

						<strong>Podpisano za pomocą:</strong>
						<br/>
						<xsl:choose>
							<xsl:when test="ds:Signature/ds:Object/xades:QualifyingProperties/xades:SignedProperties/xades:SignedSignatureProperties/xades:SignerRole/xades:ClaimedRoles/xades:ClaimedRole/ppZP:PodpisZP">
								<xsl:variable name="signer" select="ds:Signature/ds:Object/xades:QualifyingProperties/xades:SignedProperties/xades:SignedSignatureProperties/xades:SignerRole/xades:ClaimedRoles/xades:ClaimedRole/ppZP:PodpisZP"/>
								<xsl:if test="$signer/ppZP:DaneZP/ppZP:DaneZPOsobyFizycznej">
									<xsl:variable name="osobaFiz" select="$signer/ppZP:DaneZP/ppZP:DaneZPOsobyFizycznej"/>
									<xsl:value-of select="$signer/ppZP:DanePodpisu/ppZP:IdKontaUzytkownikaEpuap"/>
									<xsl:text> (</xsl:text>
									<xsl:value-of select="$osobaFiz/os:Imie"/>
									<xsl:text> </xsl:text>
									<xsl:value-of select="$osobaFiz/os:Nazwisko"/>
									<xsl:if test="$osobaFiz/os:PESEL">
										<xsl:text>, PESEL: </xsl:text>
										<xsl:value-of select="$osobaFiz/os:PESEL"/>
									</xsl:if>
									<xsl:text>)</xsl:text>
								</xsl:if>
							</xsl:when>
							<xsl:otherwise>kwalifikowany podpis elektroniczny, podpis osobisty lub podpis zaufany</xsl:otherwise>
						</xsl:choose>
					</div>
				</xsl:if>
			</body>
		</html>
	</xsl:template>

</xsl:stylesheet>