<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:epo="http://crd.gov.pl/xml/schematy/epo/2008/09/13/"
    xmlns:adr="http://crd.gov.pl/xml/schematy/adres/2008/05/09/"
    xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
    exclude-result-prefixes="epo adr ds">

	<xsl:output method="html" encoding="UTF-8" indent="yes"/>

	<xsl:template match="/">
		<html>
			<head>
				<title>Elektroniczne Potwierdzenie Opłaty (EPO)</title>
				<style>
					body { font-family: Arial, sans-serif; background-color: #f9f9f9; padding: 20px; }
					h1 { color: #1a4d80; }
					h2 { color: #2a7ab8; background-color: #e0f0ff; padding: 5px 10px; border-radius: 5px; }
					table { border-collapse: collapse; width: 90%; margin-bottom: 25px; background: #fff; box-shadow: 0 0 5px #ccc;}
					th, td { border: 1px solid #ccc; padding: 8px; text-align: left; }
					th { background-color: #f2f2f2; width: 25%; }
					.address { margin-left: 10px; }
					.signature div { margin-left: 15px; font-family: monospace; color: #444; }
				</style>
			</head>
			<body>
				<h1>Elektroniczne Potwierdzenie Opłaty (EPO)</h1>

				<!-- Odbiorca -->
				<h2>Odbiorca</h2>
				<table>
					<tr>
						<th>Nazwa</th>
						<td>
							<xsl:value-of select="epo:Odbiorca/epo:NazwaOdbiorcy"/>
						</td>
					</tr>
					<tr>
						<th>Numer rachunku</th>
						<td>
							<xsl:value-of select="epo:Odbiorca/epo:NumerRachunkuOdbiorcy"/>
						</td>
					</tr>
					<tr>
						<th>Bank</th>
						<td>
							<xsl:value-of select="epo:Odbiorca/epo:NazwaBankuOdbiorcy"/>
						</td>
					</tr>
					<tr>
						<th>Adres</th>
						<td class="address">
							<xsl:value-of select="epo:Odbiorca/epo:AdresOdbiorcy/adr:Ulica"/>
							<xsl:value-of select="epo:Odbiorca/epo:AdresOdbiorcy/adr:Budynek"/>,
							<xsl:value-of select="epo:Odbiorca/epo:AdresOdbiorcy/adr:Lokal"/><br/>
							<xsl:value-of select="epo:Odbiorca/epo:AdresOdbiorcy/adr:KodPocztowy"/>
							<xsl:value-of select="epo:Odbiorca/epo:AdresOdbiorcy/adr:Miejscowosc"/><br/>
							<xsl:value-of select="epo:Odbiorca/epo:AdresOdbiorcy/adr:Wojewodztwo"/>,
							<xsl:value-of select="epo:Odbiorca/epo:AdresOdbiorcy/adr:Kraj"/>
						</td>
					</tr>
					<xsl:for-each select="epo:Odbiorca/epo:InformacjaUzupelniajaca">
						<tr>
							<th>
								<xsl:value-of select="@TypInformacjiUzupelniajacej"/>
							</th>
							<td>
								<xsl:value-of select="."/>
							</td>
						</tr>
					</xsl:for-each>
				</table>

				<!-- Dane operacji -->
				<h2>Dane Operacji</h2>
				<table>
					<tr>
						<th>Tytuł</th>
						<td>
							<xsl:value-of select="epo:DaneOperacji/epo:TytulOperacji"/>
						</td>
					</tr>
					<tr>
						<th>Kwota</th>
						<td>
							<xsl:value-of select="epo:DaneOperacji/epo:Kwota"/>
						</td>
					</tr>
					<tr>
						<th>Data operacji</th>
						<td>
							<xsl:value-of select="epo:DaneOperacji/epo:DataOperacji"/>
						</td>
					</tr>
					<tr>
						<th>Data księgowania</th>
						<td>
							<xsl:value-of select="epo:DaneOperacji/epo:DataKsiegowania"/>
						</td>
					</tr>
					<tr>
						<th>Data wystawienia</th>
						<td>
							<xsl:value-of select="epo:DaneOperacji/epo:DataWystawieniaPotwierdzenia"/>
						</td>
					</tr>
					<tr>
						<th>Typ operacji</th>
						<td>
							<xsl:value-of select="epo:DaneOperacji/epo:TypOperacji"/>
						</td>
					</tr>
					<tr>
						<th>Identyfikator zleceniodawcy</th>
						<td>
							<xsl:value-of select="epo:DaneOperacji/epo:IdentyfikatorZleceniodawcy"/>
						</td>
					</tr>
				</table>

				<!-- Zleceniodawca -->
				<h2>Zleceniodawca</h2>
				<table>
					<tr>
						<th>Nazwa</th>
						<td>
							<xsl:value-of select="epo:Zleceniodawca/epo:NazwaZleceniodawcy"/>
						</td>
					</tr>
					<tr>
						<th>Numer rachunku</th>
						<td>
							<xsl:value-of select="epo:Zleceniodawca/epo:NumerRachunkuZleceniodawcy"/>
						</td>
					</tr>
					<tr>
						<th>Bank</th>
						<td>
							<xsl:value-of select="epo:Zleceniodawca/epo:NazwaBankuZleceniodawcy"/>
						</td>
					</tr>
					<tr>
						<th>Adres</th>
						<td class="address">
							<xsl:value-of select="epo:Zleceniodawca/epo:AdresZleceniodawcy/adr:Ulica"/>
							<xsl:value-of select="epo:Zleceniodawca/epo:AdresZleceniodawcy/adr:Budynek"/>,
							<xsl:value-of select="epo:Zleceniodawca/epo:AdresZleceniodawcy/adr:Lokal"/><br/>
							<xsl:value-of select="epo:Zleceniodawca/epo:AdresZleceniodawcy/adr:KodPocztowy"/>
							<xsl:value-of select="epo:Zleceniodawca/epo:AdresZleceniodawcy/adr:Miejscowosc"/><br/>
							<xsl:value-of select="epo:Zleceniodawca/epo:AdresZleceniodawcy/adr:Wojewodztwo"/>,
							<xsl:value-of select="epo:Zleceniodawca/epo:AdresZleceniodawcy/adr:Kraj"/>
						</td>
					</tr>
					<tr>
						<th>Email</th>
						<td>
							<xsl:value-of select="epo:Zleceniodawca/epo:AdresPocztyElektronicznej"/>
						</td>
					</tr>
					<tr>
						<th>Identyfikator</th>
						<td>
							<xsl:value-of select="epo:Zleceniodawca/epo:IdentyfikatorZleceniodawcy"/>
						</td>
					</tr>
				</table>

				<!-- Dane usługi publicznej -->
				<h2>Dane Usługi Publicznej</h2>
				<table>
					<tr>
						<th>Identyfikator wzoru</th>
						<td>
							<xsl:value-of select="epo:DaneUslugiPublicznej/epo:IdentyfikatorWzoru"/>
						</td>
					</tr>
					<tr>
						<th>Nazwa systemu inicjującego</th>
						<td>
							<xsl:value-of select="epo:DaneUslugiPublicznej/epo:NazwaSystemuInicjujacego"/>
						</td>
					</tr>
					<tr>
						<th>CID</th>
						<td>
							<xsl:value-of select="epo:DaneUslugiPublicznej/epo:CID"/>
						</td>
					</tr>
				</table>

				<!-- Wystawca -->
				<h2>Wystawca</h2>
				<table>
					<tr>
						<th>Nazwa</th>
						<td>
							<xsl:value-of select="epo:Wystawca/epo:NazwaWystawcy"/>
						</td>
					</tr>
					<tr>
						<th>Numer operacji</th>
						<td>
							<xsl:value-of select="epo:Wystawca/epo:NumerOperacji"/>
						</td>
					</tr>
				</table>

				<!-- Podpisy -->
				<h2>Podpisy Elektroniczne</h2>
				<xsl:for-each select="ds:Signature">
					<table class="signature">
						<tr>
							<th>Id</th>
							<td>
								<xsl:value-of select="@Id"/>
							</td>
						</tr>
						<tr>
							<th>SignatureValue</th>
							<td>
								<xsl:value-of select="ds:SignatureValue"/>
							</td>
						</tr>
						<tr>
							<th>KeyInfo</th>
							<td>
								<xsl:for-each select="ds:KeyInfo/ds:KeyName">
									<div>
										<xsl:value-of select="."/>
									</div>
								</xsl:for-each>
							</td>
						</tr>
					</table>

					<xsl:if test="epo:PodpisObraz">
						<h2>Podpis graficzny</h2>
						<img>
							<xsl:attribute name="src">
								<xsl:text>data:</xsl:text>
								<xsl:value-of select="epo:PodpisObraz/@format"/>
								<xsl:text>;base64,</xsl:text>
								<xsl:value-of select="epo:PodpisObraz"/>
							</xsl:attribute>
							<xsl:attribute name="style">
								max-width:400px; border:1px solid #444;
							</xsl:attribute>
						</img>
					</xsl:if>

				</xsl:for-each>

			</body>
		</html>
	</xsl:template>

</xsl:stylesheet>
