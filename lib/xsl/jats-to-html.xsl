<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xsi xs xlink mml">

	<xsl:output method="xml" indent="no" encoding="utf-8"/>

	<xsl:template match="@* | node(  )">
		<xsl:copy>
			<xsl:apply-templates select="@* | node(  )"/>
		</xsl:copy>
	</xsl:template>
	
	
	<!-- ==== FRONT MATTER START ==== -->
	
	<xsl:template match="front">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="article-meta">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="title-group">
		<div class="panel-separator"/>
		<div class="panel-pane pane-elife-article-title">
			<div class="pane-content">
				<div class="elife-article-indicators clearfix">
					<a href="http://en.wikipedia.org/wiki/Open_access">
						<img src="http://cdn-site.elifesciences.org/sites/default/modules/elife/elife_article/images/oa.png" alt="Open access" title="Open access"/>
					</a>
					<a href="http://creativecommons.org/licenses/by/4.0/">
						<img src="http://cdn-site.elifesciences.org/sites/default/modules/elife/elife_article/images/cc.png" alt="Copyright info" title="Copyright info"/>
					</a>
				</div>
				<xsl:apply-templates/>
			</div>
		</div>
		<div class="panel-separator"/>
	</xsl:template>
	
	<xsl:template match="article-title">
		<h1 class="page-title">
			<xsl:apply-templates/>
		</h1>
	</xsl:template>
	
	<!-- Author list -->
	<xsl:template match="contrib-group[not (@content-type)]">		
                <xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="contrib">
		<!-- if it has corresp attribute add corresp class-->
		<xsl:variable name ="rid" select="xref[@ref-type='aff'][1]"/>
		<!-- <xsl:variable name ="affrid" select="concat('aff', $rid)"/>-->
                <!-- modify by arul tooltip 19-9-15 pre xslt proccess start -->
		
                <xsl:apply-templates/>
	</xsl:template>
        
	<!-- modify by arul tooltip 19-9-15 pre xslt proccess start -->
	<xsl:template match="surname|given-names|name">
                <span class="nlm-given-names">
			<xsl:value-of select="given-names"/>
		</span>
        <xsl:text> </xsl:text>
		<span class="nlm-surname">                
                    <xsl:value-of select="surname"/>
		</span>
                <xsl:text>, </xsl:text>
               <xsl:value-of select="name"/>
	</xsl:template>
	
	<!-- Affiliations -->
        <xsl:key name="product" match="institution[not(@content-type)]" use="." /> 
        <xsl:template match="contrib-group[not(@content-type)]/aff">
            <div id="{@id}">
                <span class="nlm-aff">
                    <xsl:apply-templates/>
                </span>
            </div>
        </xsl:template>  
        <xsl:template match="contrib-group[not(@content-type)]/aff/institution">
             <span class="nlm-institution">
                 <xsl:if test="@content-type">
                    <xsl:attribute name="data-content-type">                    
                        <xsl:value-of select="@content-type"/>
                    </xsl:attribute>
                 </xsl:if>
                 <xsl:apply-templates/>
             </span>
        </xsl:template>  
        <xsl:template match="contrib-group[not(@content-type)]/aff/addr-line">
             <span class="nlm-addr-line">  
                <xsl:apply-templates/>
             </span>
        </xsl:template> 
        <xsl:template match="addr-line/named-content">
            <span class="nlm-named-content">  
                <xsl:if test="@content-type">
                    <xsl:attribute name="data-content-type">                    
                        <xsl:value-of select="@content-type"/>
                    </xsl:attribute>
                 </xsl:if>
                <xsl:apply-templates/>
             </span>
        </xsl:template> 
        <xsl:template match="contrib-group[not(@content-type)]/aff/country">
             <span class="nlm-country">  
                <xsl:apply-templates/>
             </span>
        </xsl:template> 
        <xsl:template match="contrib-group[not(@content-type)]/aff/x">
            <span class="nlm-x">
                <xsl:apply-templates/>
             </span>
        </xsl:template>     
        <xsl:template match="contrib-group[not(@content-type)]/aff//bold">
            <span class="nlm-bold">
                <xsl:apply-templates/>
             </span>
        </xsl:template>  
        <xsl:template match="contrib-group[not(@content-type)]/aff/email"/>
	<!-- <xsl:template match="contrib-group[not(@content-type)]/aff" mode="internal">
		<span class="elife-institution">
			
                        <xsl:for-each select="(institution[not(@content-type)])[generate-id()= generate-id(key('product',.)[1])]">
                            <xsl:variable name="temp1" select="name()"/>
                            <xsl:variable name="temp2" select='concat("nlm-",$temp1)'/>
                            <span class="{$temp2}">
                                <xsl:value-of select="."/>   
                            </span>
                            <xsl:text>, </xsl:text>
                            <span class="nlm-country">
                                <xsl:value-of select="../country" />
                            </span>
                            <xsl:if test="../following-sibling::aff">
                                    <xsl:text>; </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
		</span>
		
	</xsl:template>
	modify by arul tooltip 19-9-15 pre xslt proccess remove unwanted comma start - ->
	<xsl:template match="aff//named-content|aff/addr-line|aff/text()[preceding-sibling::institution[@content-type]][1]|aff/institution[@content-type]|aff/text()[preceding-sibling::addr-line][1]"/>
	<!- - modify by arul tooltip 19-9-15 pre xslt proccess remove unwanted comma end -->
        
	<xsl:template match="pub-date[@date-type='pub']" mode="internal">
		<span class="highwire-doi-epubdate">
			<span class="highwire-doi-epubdate-label label">Published</span> 
			<span class="highwire-doi-epubdate-data">
				<xsl:apply-templates/>
			</span>
		</span>
	</xsl:template>
	
	<xsl:template match="pub-date[@pub-type='collection']" mode="internal">
		<span class="highwire-doi-cite-as">
          <span class="highwire-doi-cite-as-label label">Cite as </span>
          <span class="highwire-doi-cite-as-data">
          	<xsl:text>eLife </xsl:text>
          	<xsl:value-of select="year"/>
          	<xsl:text>;</xsl:text>
          	<xsl:value-of select="../volume"/>
          	<xsl:text>;</xsl:text>
          	<xsl:value-of select="../elocation-id"/>
          </span>
        </span>
	</xsl:template>
	
	<xsl:template match="article-categories|article-id|aff|aff/label|author-notes|contrib/xref|permissions|pub-date|history|volume|elocation-id|self-uri|journal-meta|related-article|kwd-group|funding-group|custom-meta-group|contrib-group[@content-type='section']"/>
	<!-- ==== FRONT MATTER END ==== -->
	
	<xsl:template match="//abstract">
		<xsl:variable name="data-doi" select="child::object-id[@pub-id-type='doi']/text()"/>
		<div data-doi="{$data-doi}">
			<xsl:choose>
				<xsl:when test="./title">
					<xsl:attribute name="id">
						<xsl:value-of select="translate(translate(./title, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), ' ', '-')" />
					</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="id">
						<xsl:value-of select="name(.)" />
					</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates />
		</div>
	</xsl:template>
	<xsl:template match="abstract/title"/>


  <!-- Start transforming sections to heading levels -->
  <xsl:template match="supplementary-material">
      <xsl:variable name="id">
                    <!--<xsl:value-of select="substring-before(substring-after(@id, 'D'),'-')"/>-->
                    <xsl:value-of select="@id"/>
    </xsl:variable>
    <xsl:variable name="data-doi" select="child::object-id[@pub-id-type='doi']/text()"/>
    <div class="supplementary-material"  data-doi="{$data-doi}">
        <div class="supplementary-material-expansion" id="{$id}">
            <xsl:apply-templates />
        </div>
    </div>
    
  </xsl:template>
  
  <!-- No need to proceed sec-type="additional-information", sec-type="supplementary-material" and sec-type="datasets"-->
  <xsl:template match="sec[@sec-type='additional-information']|sec[@sec-type='datasets']|sec[@sec-type='supplementary-material']"/>
  <xsl:template match="sec[not(@sec-type='additional-information')][not(@sec-type='datasets')][not(@sec-type='supplementary-material')]">
     
  	<div>
      <xsl:if test="@sec-type">
        <xsl:attribute name="class">
          <xsl:value-of select="concat('section ', ./@sec-type)"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="@*[name()!='sec-type'] | node( )" />
	</div>
  </xsl:template>
  
  <xsl:template match="sec/title">
    <xsl:element name ="h{count(ancestor::sec) + 1}">
      <xsl:apply-templates select="@* | node( )" />
    </xsl:element>
  </xsl:template>
  <!-- END transforming sections to heading levels -->

	<xsl:template match="p">
            <xsl:if test="not(supplementary-material)">
		<p>
			
                        <xsl:if test="ancestor::caption and (count(preceding-sibling::p) = 0) and (ancestor::boxed-text or ancestor::media)">
				<xsl:attribute name="class">
					<xsl:value-of select="'first-child'" />
				</xsl:attribute>
			</xsl:if>                        
			<xsl:apply-templates />
		</p>
           </xsl:if>   
           <xsl:if test="supplementary-material">
               <xsl:if test="ancestor::caption and (count(preceding-sibling::p) = 0) and (ancestor::boxed-text or ancestor::media)">
                        <xsl:attribute name="class">
                                <xsl:value-of select="'first-child'" />
                        </xsl:attribute>
                </xsl:if>                        
                <xsl:apply-templates />
           </xsl:if>   
	</xsl:template>
	<xsl:template match="ext-link">
		<xsl:if test="@ext-link-type = 'uri'">
			<a href="{@xlink:href}">
				<xsl:apply-templates />
			</a>
		</xsl:if>
		<xsl:if test="@ext-link-type = 'doi'">
			<a href="/lookup/doi/{@xlink:href}">
				<xsl:apply-templates />
			</a>
		</xsl:if>
	</xsl:template>
	<!-- START handling citation objects -->
	<xsl:template match="xref">
            <xsl:choose>
                <xsl:when test="ancestor::fn">
                    <span class="xref-table">
                         <xsl:apply-templates />
                     </span>
                 </xsl:when>
                 <xsl:otherwise>
                     <a>
                            <xsl:attribute name="class">
                                    <xsl:value-of select="concat('xref-', ./@ref-type)" />
                            </xsl:attribute>
                            <xsl:attribute name="href">
                                    <!-- commented and modified on 13th August, 2015 -->
                                    <!-- <xsl:value-of select="concat('#', ./@rid)" />-->
                                    <!-- If xref has multiple elements in rid, then the link should points to 1st -->
                                    <xsl:choose>
                                        <xsl:when test="contains(@rid, ' ')">
                                                    <xsl:value-of select="concat('#',substring-before(@rid, ' '))" />
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="concat('#',@rid)"/>
                                        </xsl:otherwise>
                                    </xsl:choose>

                            </xsl:attribute>
                            <!--<xsl:attribute name="rel">
                                    <xsl:value-of select="concat('#', ./@rid)" />
                            </xsl:attribute>-->
                            <xsl:apply-templates />
                    </a>
                 </xsl:otherwise>   
             </xsl:choose>
	</xsl:template>
	<!-- END handling citation objects -->

	<!-- START Table Handling -->
	<xsl:template match="table-wrap">
		<xsl:variable name="data-doi" select="child::object-id[@pub-id-type='doi']/text()"/>
		
		<div class="table-wrap"  data-doi="{$data-doi}">
                    <div class="table-expansion">
                        <xsl:if test="@id">
                            <xsl:attribute name="id">
                                <xsl:value-of select="@id"/>
                            </xsl:attribute>
                        </xsl:if>
                            <xsl:apply-templates />
                    </div>   
                </div>
	</xsl:template>
	
	<xsl:template match="table-wrap/label" />
	<xsl:template match="table-wrap/label" mode="captionLabel">
		<span class="table-label">
			<xsl:apply-templates />
		</span><xsl:text> </xsl:text>
	</xsl:template>
	<xsl:template match="caption">
                <xsl:choose>
                        <!-- if article-title exists, make it as title.
                                 Otherwise, make source -->
                        <xsl:when test="not(parent::boxed-text)">
                                <div class="table-caption">
                                        <xsl:apply-templates select="parent::table-wrap/label" mode="captionLabel" />
                                        <xsl:apply-templates />
                                        <div class="sb-div caption-clear"></div>
                                </div>
                        </xsl:when>
                        <xsl:otherwise>
                                <xsl:apply-templates />
                        </xsl:otherwise>
                </xsl:choose>
		
	</xsl:template>
	<xsl:template match="table-wrap/table">
		
                    <table>
                            <xsl:apply-templates />
                    </table>                    	
	</xsl:template>
	<!-- Handle other parts of table -->
	<xsl:template match="thead|tr">
		<xsl:copy>
			<xsl:if test="@style">
				<xsl:attribute name="style">
					<xsl:value-of select="@style"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates />
		</xsl:copy>
	</xsl:template>
        <xsl:template match="tbody">
            <xsl:copy>                
                <xsl:apply-templates />
            </xsl:copy>
	</xsl:template>
        <xsl:template match="th|td">
            <xsl:copy>
                    <xsl:if test="@style">
                            <xsl:attribute name="style">
                                    <xsl:value-of select="@style"/>
                            </xsl:attribute>
                    </xsl:if>
                    <xsl:attribute name="rowspan">1</xsl:attribute>
                    <xsl:attribute name="colspan">1</xsl:attribute>
                    <xsl:apply-templates />
            </xsl:copy>
        </xsl:template>
	
	<!-- Handle Table FootNote -->
	<xsl:template match="table-wrap-foot">
		<div class="table-foot">
			<ul class="table-footnotes">
				<xsl:apply-templates />
			</ul>
		</div>
	</xsl:template>
	<xsl:template match="table-wrap-foot/fn">
		<li class="fn">
			<xsl:apply-templates />
		</li>
	</xsl:template>
        

	<xsl:template match="named-content[@content-type='author-callout-style1']">
		<span class="named-content author-callout-style1">
			<xsl:apply-templates />
		</span>
	</xsl:template>
	
        
        <xsl:template match="inline-formula">
            <span class="inline-formula">
                <xsl:apply-templates />
            </span>
        </xsl:template>
        <xsl:template match="//*[local-name()='math']">
            <span class="mathjax mml-math">
                <math>
                    <xsl:apply-templates />
                </math>
            </span>
        </xsl:template>
        
        <xsl:template match="mml:mtext">
            <xsl:choose>
                <xsl:when test="string-length(text())=1 and string-length(translate(.,'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ',''))=0">
                    <mi>
                        <xsl:variable name="normaltest" select="translate(.,'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ','')"/>
                        <xsl:attribute name="mathvariant">
                            <xsl:choose>
                                <xsl:when test="@mathvariant and string-length($normaltest)!=0">
                                    <xsl:value-of select="@mathvariant" />
                                </xsl:when>    
                                <xsl:when test="string-length($normaltest)=0">
                                    <xsl:text>normal</xsl:text>
                                </xsl:when>  
                                <xsl:otherwise>
                                    <xsl:text>normals</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:apply-templates />
                    </mi>
                </xsl:when> 
                <xsl:when test="string-length(text())=1 and string-length(translate(.,'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ',''))!=0">
                        <xsl:variable name="AllowedSymbols" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789()*%$#@!~&lt;&gt;,.?[]=- +   /\ '"/>
                       
                        <xsl:choose>
                                <xsl:when test="position()=2">
                                    <mrow><mo><xsl:apply-templates /></mo></mrow>
                                </xsl:when>
                                <xsl:when test="position()=(last()-2)">
                                    <mrow><mo><xsl:apply-templates /></mo></mrow>
                                </xsl:when>
                                <xsl:when test="following-sibling::*[1]='='">
                                    <mrow><mo><xsl:apply-templates /></mo></mrow>
                                </xsl:when>
                                <xsl:when test="preceding-sibling::*[1]='='">
                                    <mrow><mo><xsl:apply-templates /></mo></mrow>
                                </xsl:when>
                                <xsl:otherwise>
                                    <mi>
                                        <xsl:if test="@mathvariant">
                                            <xsl:attribute name="mathvariant">
                                                <xsl:value-of select="@mathvariant" />
                                            </xsl:attribute>
                                        </xsl:if>  
                                       <xsl:apply-templates />
                                    </mi>
                                </xsl:otherwise>
                        </xsl:choose>
                </xsl:when> 
                <xsl:otherwise>
                    <mtext>   
                        <xsl:if test="@mathvariant">
                            <xsl:attribute name="mathvariant">
                                <xsl:value-of select="@mathvariant" />
                            </xsl:attribute>
                        </xsl:if>
                        <xsl:apply-templates />
                    </mtext>
                </xsl:otherwise>
            </xsl:choose>
            
        </xsl:template>
        
	<!-- END Table Handling -->

	<!-- Start Figure Handling -->
	<!-- fig with atrtribute specific-use are supplement figures -->
	
	<!-- NOTE: PATH/LINK to be replaced -->
	<xsl:template match="fig-group">
		<!-- set main figure's DOI -->
		<xsl:variable name="data-doi" select="child::fig[1]/object-id[@pub-id-type='doi']/text()"/>
		
		<div class="fig-group" id="{concat('fig-group-', count(preceding::fig-group)+1)}" data-doi="{$data-doi}">
			<!-- <div id="{child::fig[not(@specific-use)]/@id}" class="fig-inline-img-set fig-inline-img-set-carousel"> -->
                        <div class="fig-inline-img-set fig-inline-img-set-carousel">
				<div class="elife-fig-slider-wrapper">
					<div class="elife-fig-slider">
						<div class="elife-fig-slider-img elife-fig-slider-primary">
						
							<!-- use variables to set src and alt -->
							
							<xsl:variable name="primarysrc" select="concat('http://cdn-site.elifesciences.org/content/elife/4/',child::fig[not(@specific-use)]/@id, '.gif')"/>
							<xsl:variable name="primarycap" select="child::fig[not(@specific-use)]//label/text()"/>
                                                        <xsl:variable name="graphichref" select="child::fig[not(@specific-use)]/graphic/@xlink:href"/>
							<img src="[graphic-{$graphichref}-small]" alt="{$primarycap}"/>
						</div>
						<div class="figure-carousel-inner-wrapper">
							<div class="figure-carousel">
								<xsl:for-each select="child::fig[@specific-use]">
									<!-- use variables to set src and alt -->
									<xsl:variable name="secondarysrc" select="concat('http://cdn-site.elifesciences.org/content/elife/4/',@id, '.gif')"/>
									<xsl:variable name="secondarycap" select="child::label/text()"/>
                                                                        <xsl:variable name="secgraphichref" select="child::graphic/@xlink:href"/>
									<div class="elife-fig-slider-img elife-fig-slider-secondary">
										<img src="[graphic-{$secgraphichref}-small]" alt="{$secondarycap}"/>
									</div>
								</xsl:for-each>
							</div>
						</div>
					</div>
				</div>
				<div class="elife-fig-image-caption-wrapper">
					<xsl:apply-templates />
				</div>
			</div>
		</div>
	</xsl:template>
	
	<!-- individual fig in fig-group -->
	
	<xsl:template match="//fig">
		<xsl:variable name="caption" select="child::label/text()"/>
		<xsl:variable name="data-doi" select="child::object-id[@pub-id-type='doi']/text()"/>
                <xsl:variable name="id">
                    <!--<xsl:value-of select="count(preceding::fig)+1" />-->
                    <xsl:value-of select="@id" />
                </xsl:variable>
                <xsl:variable name="graphics" select="child::graphic/@xlink:href"/>
                <div class="fig" data-doi="{$data-doi}">
                    <div id="{$id}" class="fig-inline-img-set">
                            <div class="elife-fig-image-caption-wrapper">
                                    <div class="fig-expansion">
                                            <div class="fig-inline-img">
                                                    <a href="[graphic-{$graphics}-large]" class="figure-expand-popup" title="{$caption}">
                                                            <img data-img="[graphic-{$graphics}-small]" src="[graphic-{$graphics}-medium]" alt="{$caption}"/>
                                                    </a>
                                            </div>
                                            <xsl:apply-templates />
                                    </div>
                            </div>
                    </div>
                </div>
	</xsl:template>
	
	<!-- fig caption -->
	<xsl:template match="fig//caption">
                <xsl:choose>
                       
                        <xsl:when test="not(parent::supplementary-material)">
                                <div class="fig-caption">
                                    <xsl:variable name="graphics" select="../graphic/@xlink:href"/>
                                    <!-- three options -->
                                    <span class="elife-figure-links">
                                            <span class="elife-figure-link elife-figure-link-download">
                                                    <a href="[graphic-{$graphics}-large-download]">Download figure</a>
                                            </span>
                                            <span class="elife-figure-link elife-figure-link-newtab">
                                                    <a href="[graphic-{$graphics}-large]" target="_new">Open in new tab</a>
                                            </span>
                                    </span>
                                    <span class="fig-label">
                                            <xsl:value-of select="../label/text()"/>
                                    </span><xsl:text> </xsl:text>
                                    <xsl:apply-templates />
                                    <div class="sb-div caption-clear"></div>
                            </div>
                            
                        </xsl:when>
                        <xsl:otherwise>
                            <span class="supplementary-material-label">
                                <xsl:value-of select="../label/text()"/>
                            </span>
                            <xsl:apply-templates />
                        </xsl:otherwise>
                </xsl:choose>
		
	</xsl:template>
        <xsl:template match="fig/graphic"/>
	
	<xsl:template match="fig//caption/title">
		<span class="caption-title">
			<xsl:apply-templates />
		</span>
	</xsl:template>
	
	<xsl:template match="fig//ext-link">
            <xsl:if test="ancestor::supplementary-material or @ext-link-type='doi'">
		<a href="/lookup/doi/{@xlink:href}">
			<xsl:apply-templates />
		</a>
            </xsl:if>
            <xsl:if test="not(ancestor::supplementary-material) and @ext-link-type!='doi'">
                <a href="{@xlink:href}">
			<xsl:apply-templates />
		</a>
            </xsl:if>
	</xsl:template>
	
	<!-- reset unwanted -->
	<xsl:template match="fig-group//object-id|fig-group//graphic|fig//label"/>
	
	<!-- END Figure Handling -->
	
	<!-- STARTED By Lingasamy. S -->
	
	<!-- body content -->
	<xsl:template match="body">
		<xsl:variable name="data-doi" select="../front/article-meta/article-id[@pub-id-type='doi']/text()"/>
                <div class="elife-article-decision-letter">
                        
                         <xsl:apply-templates />
                        
                </div>
                <div class="elife-article-decision-letter" id='main-text'>
                        <div class="article fulltext-view">
                               <!-- <xsl:call-template name="testrenderApplicationsDrop" />  -->
                                <xsl:apply-templates  mode="testing"/>
                        </div>
                </div>
	</xsl:template>
        
       <xsl:template match="sec[@sec-type='additional-information']|sec[@sec-type='datasets']|sec[@sec-type='supplementary-material']"  mode="testing"/>
      <xsl:template match="sec[not(@sec-type='additional-information')][not(@sec-type='datasets')][not(@sec-type='supplementary-material')]/@id"  mode="testing"/>
      <xsl:template match="sec[not(@sec-type='additional-information')][not(@sec-type='datasets')][not(@sec-type='supplementary-material')]"  mode="testing">
     
            <div>
          
          <xsl:if test="@sec-type">
            <xsl:attribute name="class">
              <xsl:value-of select="concat('section ', ./@sec-type)"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="@id">
            <xsl:attribute name="id">
              <xsl:value-of select="@id"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="not(@sec-type)">
            <xsl:attribute name="class">
              <xsl:value-of select="'subsection'"/>
            </xsl:attribute>
          </xsl:if>
          
          <xsl:apply-templates  mode="testing" />
            </div>
      </xsl:template>
      
      <xsl:template match="sec/title" mode="testing">
        <xsl:element name ="h{count(ancestor::sec) + 1}">
          <xsl:apply-templates select="@* | node( )" />
        </xsl:element>
      </xsl:template>
      <xsl:template match="p"  mode="testing">
            <xsl:if test="not(supplementary-material)">
		<p>
			
                        <xsl:if test="ancestor::caption and (count(preceding-sibling::p) = 0) and (ancestor::boxed-text or ancestor::media)">
				<xsl:attribute name="class">
					<xsl:value-of select="'first-child'" />
				</xsl:attribute>
			</xsl:if>                        
			<xsl:apply-templates mode="testing"/>
		</p>
           </xsl:if>   
           <xsl:if test="supplementary-material">
               <xsl:if test="ancestor::caption and (count(preceding-sibling::p) = 0) and (ancestor::boxed-text or ancestor::media)">
                        <xsl:attribute name="class">
                                <xsl:value-of select="'first-child'" />
                        </xsl:attribute>
                </xsl:if>                        
                <xsl:apply-templates mode="testing"/>
           </xsl:if>   
	</xsl:template>
        <xsl:template match="xref" mode="testing">
            <xsl:choose>
                <xsl:when test="ancestor::fn">
                    <span class="xref-table">
                         <xsl:apply-templates />
                     </span>
                 </xsl:when>
                 <xsl:otherwise>
                     <a>
                            <xsl:attribute name="class">
                                    <xsl:value-of select="concat('xref-', ./@ref-type)" />
                            </xsl:attribute>
                            <xsl:attribute name="href">
                                    <!-- commented and modified on 13th August, 2015 -->
                                    <!-- <xsl:value-of select="concat('#', ./@rid)" />-->
                                    <!-- If xref has multiple elements in rid, then the link should points to 1st -->
                                    <xsl:choose>
                                        <xsl:when test="contains(@rid, ' ')">
                                                    <xsl:value-of select="concat('#',substring-before(@rid, ' '))" />
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="concat('#',@rid)"/>
                                        </xsl:otherwise>
                                    </xsl:choose>

                            </xsl:attribute>
                            <!--<xsl:attribute name="rel">
                                    <xsl:value-of select="concat('#', ./@rid)" />
                            </xsl:attribute>-->
                            <xsl:apply-templates />
                    </a>
                 </xsl:otherwise>   
             </xsl:choose>
	</xsl:template>
        
        <xsl:template match="table-wrap" mode="testing">
		<xsl:variable name="data-doi" select="child::object-id[@pub-id-type='doi']/text()"/>
                    <div class="table-expansion">
                        <xsl:if test="@id">
                            <xsl:attribute name="id">
                                <xsl:value-of select="@id"/>
                            </xsl:attribute>
                        </xsl:if>
                            <xsl:apply-templates mode="testing"/>
                            
                            <!--<xsl:if test="table-wrap-foot">
                                <div class="table-foot">
                                        <ul class="table-footnotes">
                                             <xsl:for-each select="table-wrap-foot/fn">
                                                 <li class="fn">
                                                     <xsl:attribute name="id">
                                                        <xsl:value-of select="count(ancestor::table-wrap/ancestor::sec//table-wrap//fn)"/>
                                                    </xsl:attribute>
                                                     <xsl:apply-templates mode="rendertablefoot"/>
                                                 </li>
                                             </xsl:for-each>
                                        </ul>
                                </div>
                            </xsl:if>-->
                    </div>
	</xsl:template>
        
        <xsl:template match="caption" mode="testing">
                <xsl:choose>
                        <!-- if article-title exists, make it as title.
                                 Otherwise, make source -->
                        <xsl:when test="not(parent::boxed-text)">
                                <div class="table-caption">
                                        <xsl:apply-templates select="parent::table-wrap/label" mode="captionLabel" />
                                        <xsl:apply-templates />
                                        <div class="sb-div caption-clear"></div>
                                </div>
                        </xsl:when>
                        <xsl:otherwise>
                                <xsl:apply-templates />
                        </xsl:otherwise>
                </xsl:choose>
		
	</xsl:template>
	<xsl:template match="table-wrap/table" mode="testing">
		
                    <table frame="hsides" rules="groups">
                            <xsl:apply-templates />
                    </table>                    	
	</xsl:template>
        
        <!--<xsl:template match="table-wrap-foot/fn"  mode="rendertablefoot">
		
			<xsl:apply-templates />
		
	</xsl:template>-->
        <xsl:template match="table-wrap-foot"  mode="testing">
		<div class="table-foot">
			<ul class="table-footnotes">
				<xsl:apply-templates mode="testing" />
			</ul>
		</div>
	</xsl:template>
	<xsl:template match="fn" mode="testing">
		<li class="fn">
                   <!-- <xsl:if test="not(../child::fn/@id)">
                        <xsl:attribute name="id">
                            <xsl:value-of select="concat('fn-',count(preceding::fn)+1)"/>
                        </xsl:attribute>
                    </xsl:if>-->
			<xsl:apply-templates />
		</li>
	</xsl:template>
	<xsl:template match="object-id|table-wrap/label" mode="testing"/>
        
        <xsl:template match="boxed-text"  mode="testing">
		<xsl:variable name="data-doi" select="child::object-id[@pub-id-type='doi']/text()"/>
		
		<!-- below div commented and a new line added on 12th August, 2015
			 For the citation links, take the id from the boxed-text -->
                <xsl:choose>
                        <xsl:when test="child::object-id[@pub-id-type='doi']/text()!=''">
                                <div class="boxed-text">
                                    <xsl:attribute name="id">
                                        <xsl:value-of select="@id"/>
                                    </xsl:attribute>
                                        <xsl:apply-templates/>
                                </div>
                        </xsl:when>
                        <xsl:otherwise>
                                <div class="boxed-text">
                                        <xsl:apply-templates/>
                                </div>
                                
                        </xsl:otherwise>
                </xsl:choose>
                
		
		
	</xsl:template>
        
        <xsl:template match="bold" mode="testing">
		<strong>
			<xsl:apply-templates/>
		</strong>
	</xsl:template>
	
	<xsl:template match="italic" mode="testing">
		<em>
                    <xsl:apply-templates/>
		</em>
	</xsl:template>
        <xsl:template match="sub" mode="testing">
		<sub>
                    <xsl:apply-templates/>
		</sub>
	</xsl:template>
        <xsl:template match="sup" mode="testing">
		<sup>
                    <xsl:apply-templates/>
		</sup>
	</xsl:template>
        
        <xsl:template match="//fig"  mode="testing">
		<xsl:variable name="caption" select="child::label/text()"/>
		<xsl:variable name="data-doi" select="child::object-id[@pub-id-type='doi']/text()"/>
                <xsl:variable name="id">
                    <!--<xsl:value-of select="count(preceding::fig)+1" />-->
                    <xsl:value-of select="@id" />
                </xsl:variable>
                <xsl:variable name="graphics" select="child::graphic/@xlink:href"/>
                <div id="{$id}" class="fig-inline-img-set">
                            <div class="elife-fig-image-caption-wrapper">
                                    <div class="fig-expansion">
                                            <div class="fig-inline-img">
                                                    <a href="[graphic-{$graphics}-large]" class="figure-expand-popup" title="{$caption}">
                                                            <img data-img="[graphic-{$graphics}-small]" src="[graphic-{$graphics}-medium]" alt="{$caption}"/>
                                                    </a>
                                            </div>
                                            <xsl:apply-templates />
                                    </div>
                            </div>
                </div>
	</xsl:template>
        
        <xsl:template match="fig-group"  mode="testing">
		<!-- set main figure's DOI -->
		<xsl:variable name="data-doi" select="child::fig[1]/object-id[@pub-id-type='doi']/text()"/>
			<!-- <div id="{child::fig[not(@specific-use)]/@id}" class="fig-inline-img-set fig-inline-img-set-carousel"> -->
                        <div class="fig-inline-img-set fig-inline-img-set-carousel">
				<div class="elife-fig-slider-wrapper eLifeArticleFiguresSlider-processed">
					<div class="elife-fig-slider">
						<div class="elife-fig-slider-img elife-fig-slider-primary">
						
							<!-- use variables to set src and alt -->
							
							<xsl:variable name="primarysrc" select="concat('http://cdn-site.elifesciences.org/content/elife/4/',child::fig[not(@specific-use)]/@id, '.gif')"/>
							<xsl:variable name="primarycap" select="child::fig[not(@specific-use)]//label/text()"/>
                                                        <xsl:variable name="graphichref" select="child::fig[not(@specific-use)]/graphic/@xlink:href"/>
							<img data-fragment-nid="" class="figure-icon-fragment-nid-" src="{$primarysrc}" alt="{$primarycap}"/>
						</div>
						<div class="figure-carousel-inner-wrapper">
							<div class="figure-carousel figure-carousel-">
								<xsl:for-each select="child::fig[@specific-use]">
									<!-- use variables to set src and alt -->
									<xsl:variable name="secondarysrc" select="concat('http://cdn-site.elifesciences.org/content/elife/4/',@id, '.gif')"/>
									<xsl:variable name="secondarycap" select="child::label/text()"/>
                                                                        <xsl:variable name="secgraphichref" select="child::graphic/@xlink:href"/>
									<div class="elife-fig-slider-img elife-fig-slider-secondary">
										<img data-fragment-nid="" class="figure-icon-fragment-nid-" src="{$secondarysrc}" alt="{$secondarycap}"/>
									</div>
								</xsl:for-each>
							</div>
						</div>
					</div>
				</div>
				<div class="elife-fig-image-caption-wrapper">
					<xsl:apply-templates />
				</div>
			</div>
	</xsl:template>
        
        
        <xsl:template match="media" mode="testing">
		<xsl:variable name="data-doi" select="child::object-id[@pub-id-type='doi']/text()"/>
		
		<xsl:choose>
			<xsl:when test="@mimetype = 'application'">
				<!-- if mimetype is application -->
				<span class="inline-linked-media-wrapper">
					<a href="[media-{substring-before(@xlink:href,'.')}-download]">
						<i class="icon-download-alt"></i> Download source data<span class="inline-linked-media-filename">[<xsl:value-of select="translate(translate(preceding-sibling::label, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), ' ', '-')"/>media-<xsl:value-of select="count(preceding::media[@mimetype = 'application'])+1" />.<xsl:value-of select="substring-after(@xlink:href,'.')"/>]</span>
                                                <!--<xsl:value-of select="concat('[', @xlink:href, ']')"></xsl:value-of>-->
					</a>
				</span>
			</xsl:when>
			<xsl:otherwise>
				<!-- otherwise -->
                                    <div class="media video-content">
                                            <!-- set attribute -->
                                            <xsl:attribute name="id">
                                                <!-- <xsl:value-of select="concat('media-', @id)"/>-->
                                                <xsl:value-of select="@id"/>
                                            </xsl:attribute>
                                            <div class="media-inline video-inline">
                                                    <div class="elife-inline-video">
                                                            <xsl:text> [video-</xsl:text><xsl:value-of select="@id"/><xsl:text>-inline] </xsl:text>

                                                            <div class="elife-video-links">
                                                                    <span class="elife-video-link elife-video-link-download">
                                                                            <a href="[video-{@id}-download]">Download Video</a>
                                                                            
                                                                    </span>
                                                            </div>
                                                    </div>
                                            </div>
                                            <xsl:apply-templates/>
                                    </div>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
        <xsl:template match="//media/caption" mode="testing">
		<div class="media-caption">	
                        <span class="media-label">
				<xsl:value-of select="preceding-sibling::label"/>
			</span><xsl:text> </xsl:text>
			<xsl:apply-templates mode="testing"/>
		</div>
	</xsl:template>
	
	<xsl:template match="//media/label" mode="testing"/>
	<xsl:template match="//media/caption/title" mode="testing">
            <span class="caption-title">
		<xsl:apply-templates/>
            </span>
	</xsl:template>
        <xsl:template name="renderApplicationsDrop">
            <xsl:param name="string" select="$string" />
            <xsl:for-each select="$string/*">
                <!--<xsl:if test="count(child::*) = 0">
                    <xsl:apply-templates />
                </xsl:if>
                <xsl:if test="count(child::*) != 0">
                    <xsl:value-of select="concat(count(child::*),' ',name(.))"/>
                    <xsl:call-template name="renderApplicationsDrop">
                        <xsl:with-param name="string" select="." />
                     </xsl:call-template>
                </xsl:if>-->
                <xsl:if test="count(child::*) != 0">
                   
                    <xsl:choose>
                        <xsl:when test="fig">
                            <xsl:value-of select="name(.)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="name(.)"/>
                            <xsl:apply-templates/>
                        </xsl:otherwise>                            
                    </xsl:choose>
                </xsl:if>
            </xsl:for-each>
        </xsl:template>
	<!-- Acknowledgement -->
	
	<xsl:template match="ack">
		<div class="ctools-collapsible-container ctools-collapsible-processed">
			<span class="ctools-toggle"></span>
			<xsl:apply-templates />
		</div>
	</xsl:template>
	
	<xsl:template match="ack/title">
		<h2 class="pane-title ctools-collapsible-handle">
			<xsl:apply-templates />
		</h2>
	</xsl:template>

	<xsl:template match="ack/p">
        <div id="ack-1">
            <p>
                <xsl:apply-templates />
            </p>
        </div>
	</xsl:template>
	<!-- START Reference Handling -->
	
	<xsl:template match="ref-list">
		<div id="references" class="ctools-collapsible-container ctools-collapsible-processed">
			
				<div class="elife-reflinks-links">
					<xsl:apply-templates />
				</div>
		</div>
	</xsl:template>
	
	<xsl:template match="ref-list/title"/>
	
	<xsl:template match="ref">
		<article class="elife-reflinks-reflink" id="{@id}">
                        <xsl:attribute name="data-original">                                                
                                <xsl:value-of select="translate(@id,'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ','')"/>
                       </xsl:attribute>
			<!-- set attribute -->
			<xsl:variable name="slno" select="translate(@id,'bib','')"/>
			<div class="elife-reflink-indicators">
				<div class="elife-reflink-indicators-left">
					<div class="elife-reflink-indicator-number">
						<span data-counter="{$slno}">
							<!-- modify by arul ref number display -->
							<xsl:value-of select="(count(preceding::ref)+1)"/>
							<!-- modify by arul ref number display end-->
						</span>
					</div>
					
				</div>
				
			</div>
			<xsl:apply-templates />
		</article>
	</xsl:template>
	
	<xsl:template match="ref/element-citation">
		<xsl:variable name="refid" select="../@id"/>
		<xsl:variable name="doi" select="pub-id"/>
		
		<xsl:variable name="href" select="concat('http://dx.doi.org/',$doi)"/>		
		
                <div class="elife-reflink-main">
			<cite class="elife-reflink-title">
				<!-- If publication-type is journal, then <a> tag is needed. Otherwise (book), No need for <a> tag -->
				<xsl:choose>
					<xsl:when test="@publication-type = 'journal' and pub-id != ''">
						<a href="{$href}" target="_blank">
							<span class="nlm-article-title">
								<xsl:apply-templates select="child::article-title/node()"/>
							</span>
						</a>
					</xsl:when>
                                        <xsl:when test="@publication-type = 'journal' and string(pub-id) = ''">
                                                <span class="nlm-article-title">
                                                        <xsl:apply-templates select="child::article-title/node()"/>
                                                </span>
					</xsl:when>
					<xsl:when test="@publication-type = 'book'">
						<xsl:choose>
							<!-- if article-title exists, make it as title.
								 Otherwise, make source -->
							<xsl:when test="child::article-title">
								<span class="nlm-article-title">
									<xsl:apply-templates select="child::article-title/node()"/>
								</span>
							</xsl:when>
							<xsl:otherwise>
								<span class="nlm-source">
									<xsl:apply-templates select="child::source/node()"/>
								</span>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="@publication-type = 'web'">
						<a href="{$href}">
							<span class="nlm-comment">
								<xsl:apply-templates select="child::comment/node()"/>
							</span>
						</a>
					</xsl:when>
				</xsl:choose>
			</cite>
			
			<!-- call authors template -->
			<!-- <xsl:call-templates select="authors"></xsl:call-templates>-->
			
			<xsl:if test="person-group[@person-group-type='author']">
				<div class="elife-reflink-authors">
					<xsl:for-each select="person-group[@person-group-type='author']">
						<xsl:for-each select="child::name">
							<xsl:variable name="givenname" select="child::given-names"/>
							<xsl:variable name="surname" select="child::surname"/>
                                                        <xsl:variable name="suffix" select="child::suffix"/>
                                                        <xsl:variable name="fullname">
                                                            <xsl:choose>
                                                                <xsl:when test="string($suffix) != ''">
                                                                    <xsl:value-of select="concat($givenname, ' ', $surname, ' ', $suffix)"/>
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    <xsl:value-of select="concat($givenname, ' ', $surname)"/>
                                                                </xsl:otherwise>
                                                            </xsl:choose>
							</xsl:variable>
							<xsl:variable name="hrefvalue" select="concat('http://scholar.google.com/scholar?q=&quot;author:',$fullname,'&quot;')"/>
							<span class="elife-reflink-author">
								<a href="{$hrefvalue}">
									<xsl:value-of select="$fullname"/>
								</a>
							</span>
							<!-- if next name exists then add comma(,) -->
							<xsl:if test="following-sibling::name">
								<xsl:text>, </xsl:text>
							</xsl:if>
							<!-- for etal exists, then add ( et al.) -->
							<!-- <xsl:if test="following-sibling::etal"> -->
							<xsl:if test="position() = last() and following-sibling::etal">
								<xsl:text> et al. </xsl:text>
							</xsl:if>
						</xsl:for-each>
						<!-- Handle collab -->
						<xsl:for-each select="child::collab">
							<span class="nlm-collab">
								<xsl:apply-templates/>
							</span>
							<!-- if next name exists then add comma(,) -->
							<xsl:if test="following-sibling::collab">
								<xsl:text>, </xsl:text>
							</xsl:if>
						</xsl:for-each>
					</xsl:for-each>
				</div>
			</xsl:if>
			
			<!-- <xsl:if test="person-group[@person-group-type='editor']">
				<div class="elife-reflink-editors">
					<xsl:for-each select="person-group[@person-group-type='editor']">
						<xsl:for-each select="child::name">
							<xsl:variable name="givenname" select="child::given-names"/>
							<xsl:variable name="surname" select="child::surname"/>
							<xsl:variable name="fullname" select="concat($givenname, ' ', $surname)"/>
							<xsl:variable name="hrefvalue" select="concat('http://scholar.google.com/scholar?q=&quot;author:',$fullname,'&quot;')"/>
							<span class="elife-reflink-editor">
								<a href="{$hrefvalue}">
									<xsl:value-of select="$fullname"/>
								</a>
							</span>
							<xsl:if test="following-sibling::name">
								<xsl:text>, </xsl:text>
							</xsl:if>
						</xsl:for-each>
					</xsl:for-each>
				</div>
			</xsl:if> -->
			
			<!-- call details template -->
			<!--<xsl:call-templates select="details"></xsl:call-templates>-->
			
			<!-- move all other elements into details div 
				and comma separate
			-->
			<div class="elife-reflink-details">
				<xsl:if test="child::source and (@publication-type='journal')">
					<span class="elife-reflink-details-journal">
						<span class="nlm-source">
							<xsl:apply-templates select="child::source/node()"/>
						</span>
					</span>
					<xsl:if test="child::source/following-sibling::*">
						<xsl:text>, </xsl:text>
					</xsl:if>
				</xsl:if>
				<!-- For book, if article-title exists, source alowed here.
					 If article-title doesn't exists, then source to be moved at the top(title).
					 So, source will not be allowed here -->
				<xsl:if test="child::article-title and child::source and (@publication-type='book')">
					<span class="elife-reflink-details-journal">
						<span class="nlm-source">
							<xsl:apply-templates select="child::source/node()"/>
						</span>
					</span>
					<xsl:if test="child::source/following-sibling::*">
						<xsl:text>, </xsl:text>
					</xsl:if>
				</xsl:if>
				<xsl:if test="child::publisher-name">
					<span class="elife-reflink-details-pub-name">
						<span class="nlm-publisher-name">
							<xsl:apply-templates select="child::publisher-name/node()"/>
						</span>
					</span>
					<xsl:if test="child::publisher-loc">
						<xsl:text>, </xsl:text>
					</xsl:if>
				</xsl:if>
				<xsl:if test="child::publisher-loc">
					<span class="elife-reflink-details-pub-loc">
						<span class="nlm-publisher-loc">
							<xsl:apply-templates select="child::publisher-loc/node()"/>
						</span>
					</span>
					<xsl:if test="child::publisher-loc/following-sibling::*">
						<xsl:text>, </xsl:text>
					</xsl:if>
				</xsl:if>
				<xsl:if test="child::volume">
					<span class="elife-reflink-details-volume">
						<xsl:apply-templates select="child::volume/node()"/>
					</span>
					<xsl:if test="child::volume/following-sibling::*">
						<xsl:text>, </xsl:text>
					</xsl:if>
				</xsl:if>
				<xsl:if test="child::fpage">
					<span class="elife-reflink-details-pages">
						<xsl:apply-templates select="child::fpage/node()"/>
						<xsl:if test="child::lpage">
							<xsl:text>-</xsl:text>
							<xsl:value-of select="child::lpage/text()"/>
						</xsl:if>
					</span>
					<xsl:if test="child::fpage/following-sibling::*">
						<xsl:text>, </xsl:text>
					</xsl:if>
				</xsl:if>
				<xsl:if test="child::year">
					<span class="elife-reflink-details-year">
						<xsl:apply-templates select="child::year/node()"/>
					</span>
				</xsl:if>
				
				<!-- DOI in references -->
				
					<!-- check whether pib-id or ex-link exist. -->
					<xsl:if test="child::pub-id">
                                            <div class="elife-reflink-doi-cited-wrapper">
						<xsl:variable name="doivalue" select="child::pub-id/node()"></xsl:variable>
						<span class="elife-reflink-details-doi">
							<a href="{concat('http://dx.doi.org/', $doivalue)}">
								<xsl:value-of select="concat('http://dx.doi.org/', $doivalue)"/>
							</a>
						</span>
						<!-- count no.of cited 
						<xsl:text> — </xsl:text>-->
                                            </div>
					</xsl:if>
					<xsl:if test="child::ext-link">
                                            <div class="elife-reflink-doi-cited-wrapper">
						<xsl:variable name="doivalue" select="child::ext-link/node()"></xsl:variable>
						<span class="elife-reflink-details-doi">
							<a href="{concat('http://dx.doi.org/', $doivalue)}">
								<xsl:value-of select="concat('http://dx.doi.org/', $doivalue)"/>
							</a>
						</span>
						
                                            </div>
					</xsl:if>
					
				
			</div>
			<xsl:apply-templates />
		</div>
	</xsl:template>
	
	<!-- reset unwanted -->
	<xsl:template match="ref//year|ref//article-title|ref//fpage|ref//volume|ref//source|ref//pub-id|ref//lpage|ref//comment|ref//supplement|ref//person-group[@person-group-type='editor']|ref//edition|ref//publisher-loc|ref//publisher-name|ref//ext-link"/>
	
	<!-- reference authors -->
	<xsl:template match="person-group[@person-group-type='author']"/>
	<!-- END Reference Handling -->

	<!-- START Appendix -->
	
	<xsl:template match="app-group">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="app">
		<div class="section app" id="{@id}">
			<xsl:apply-templates/>
		</div>
	</xsl:template>
	
	<xsl:template match="app/title">
		<h2>
			<xsl:apply-templates/>
		</h2>
	</xsl:template>
	
	<!-- END Appendix -->
	
	<!-- START Equations -->
        <!-- modify by arul tooltip 19-9-15 pre xslt proccess equation start -->
	<xsl:template match="disp-formula">
            <span class="disp-formula" id="{@id}" style="font-size: smaller;">
                <xsl:apply-templates select="math"/>
                <span class="disp-formula-label">
                    <xsl:value-of select="label"/>
                </span>
            </span>    
        </xsl:template> 
        <!-- modify by arul tooltip 19-9-15 pre xslt proccess equation end -->
	
	<!-- Equation label -->
	<xsl:template match="disp-formula/label">
		<span class="disp-formula-label">
			<xsl:apply-templates/>
		</span>
	</xsl:template>
	
	
	<!-- END Equations -->
	
	<!-- START video handling -->
	
	<xsl:template match="media">
		<xsl:variable name="data-doi" select="child::object-id[@pub-id-type='doi']/text()"/>
		
		<xsl:choose>
			<xsl:when test="@mimetype = 'application'">
				<!-- if mimetype is application -->
				<span class="inline-linked-media-wrapper">
					<a href="[media-{substring-before(@xlink:href,'.')}-download]">
						<i class="icon-download-alt"></i> Download source data<span class="inline-linked-media-filename">[<xsl:value-of select="translate(translate(preceding-sibling::label, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), ' ', '-')"/>media-<xsl:value-of select="count(preceding::media[@mimetype = 'application'])+1" />.<xsl:value-of select="substring-after(@xlink:href,'.')"/>]</span>
                                                <!--<xsl:value-of select="concat('[', @xlink:href, ']')"></xsl:value-of>-->
					</a>
				</span>
			</xsl:when>
			<xsl:otherwise>
				<!-- otherwise -->
                                <div class="media"  data-doi="{$data-doi}">
                                    <div class="media video-content">
                                            <!-- set attribute -->
                                            <xsl:attribute name="id">
                                                <!-- <xsl:value-of select="concat('media-', @id)"/>-->
                                                <xsl:value-of select="@id"/>
                                            </xsl:attribute>
                                            <div class="media-inline video-inline">
                                                    <div class="elife-inline-video">
                                                            <xsl:text>[video-</xsl:text><xsl:value-of select="@id"/><xsl:text>-inline]</xsl:text>

                                                            <div class="elife-video-links">
                                                                    <span class="elife-video-link elife-video-link-download">
                                                                            <a href="[video-{@id}-download]">Download Video</a>
                                                                            
                                                                    </span>
                                                            </div>
                                                    </div>
                                            </div>
                                            <xsl:apply-templates/>
                                    </div>
                                </div>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- media caption -->
	<xsl:template match="//media/caption">
		<div class="media-caption">
			<span class="media-label">
				<xsl:value-of select="preceding-sibling::label"/>
			</span><xsl:text> </xsl:text>
			<!--<xsl:text> </xsl:text>-->
			
			<xsl:apply-templates/>
		</div>
	</xsl:template>
	
	<xsl:template match="//media/label"/>
	
	<xsl:template match="//media/caption/title">
            <span class="caption-title">
		<xsl:apply-templates/>
            </span>
	</xsl:template>
	
	<!-- END video handling -->
	
	<!-- START sub-article -->
	
	<xsl:template match="sub-article">
		<xsl:variable name="data-doi" select="child::front-stub/article-id[@pub-id-type='doi']/text()"/>
		<div data-doi="{$data-doi}">
			<!-- determine the attribute -->
			<xsl:attribute name="id">
				<xsl:if test="@article-type='article-commentary'">
					<xsl:text>decision-letter</xsl:text>
				</xsl:if>
				<xsl:if test="@article-type='reply'">
					<xsl:text>author-response</xsl:text>
				</xsl:if>
			</xsl:attribute>
			<xsl:call-template name="subarticle-title"/>
                        
		</div>
		<div class="panel-separator"></div>
	</xsl:template>
	
        
         <xsl:template match="sub-article//title-group" name="subarticle-title">
			<xsl:apply-templates/>
	</xsl:template>
        
	
	<xsl:template match="sub-article//article-title"/>
	
	<xsl:template match="sub-article/front-stub">
		<xsl:apply-templates/>
	</xsl:template>
	
	<!-- sub-article body -->
        <xsl:template match="sub-article/body">
		<div>
			
			<xsl:attribute name="class">
				<xsl:if test="../@article-type='article-commentary'">
					<xsl:text>elife-article-decision-letter</xsl:text>
				</xsl:if>
				<xsl:if test="../@article-type='reply'">
					<xsl:text>elife-article-author-response</xsl:text>
				</xsl:if>
			</xsl:attribute>
			
                        <div class="article fulltext-view">
                                <xsl:apply-templates/>
                        </div>
				
                        
		</div>
                <div>
                        <xsl:attribute name="class">
                                <xsl:if test="../@article-type='article-commentary'">
                                        <xsl:text>elife-article-decision-letter-doi</xsl:text>
                                </xsl:if>
                                <xsl:if test="../@article-type='reply'">
                                        <xsl:text>elife-article-author-response-doi</xsl:text>
                                </xsl:if>
                        </xsl:attribute>
                        <strong>DOI:</strong><xsl:text> </xsl:text>

                        <xsl:variable name="doino" select="preceding-sibling::*//article-id" />
                        <a href="/lookup/doi/{$doino}">
                                <xsl:text>http://dx.doi.org/</xsl:text>
                                <xsl:value-of select="$doino" />
                        </a>
                </div>
		
	</xsl:template>
	
	
	<xsl:template match="sub-article//article-id"/>
	
	<!-- START sub-article author contrib information -->
	
	<xsl:template match="sub-article//contrib-group">
		<div class="elife-article-editors">
			<xsl:apply-templates />
		</div>
	</xsl:template>
	
	<xsl:template match="sub-article//contrib-group/contrib">
		<div>
			<xsl:attribute name="class">
				<xsl:value-of select="concat('elife-article-decision-reviewing', @contrib-type)" />
			</xsl:attribute>
			<xsl:apply-templates />
		</div>
	</xsl:template>
	<xsl:template match="sub-article//name/given-names|sub-article//name/surname">
                <span class="nlm-given-names">
			<xsl:value-of select="given-names"/>
		</span>  
                <xsl:text> </xsl:text>
		<span class="nlm-surname">                
                    <xsl:value-of select="surname"/>
		</span>
                <xsl:text>, </xsl:text>
               <xsl:value-of select="name"/>
	</xsl:template>
	<xsl:template match="sub-article//aff">
		<xsl:apply-templates />
		<xsl:if test="following-sibling::*">
			<xsl:text>, </xsl:text>
		</xsl:if>
	</xsl:template>
        <xsl:template match="sub-article//role">
		<span class="nlm-role">
			<xsl:apply-templates />
		</span>
                <xsl:text>, </xsl:text>
	</xsl:template>
	
	<xsl:template match="sub-article//institution">
		<span class="nlm-institution">
			<xsl:apply-templates />
		</span>
	</xsl:template>
	
	<xsl:template match="sub-article//country">
		<span class="nlm-country">
			<xsl:apply-templates />
		</span>
	</xsl:template>
	
	<!-- END sub-article author contrib information -->
	
	<!-- box text -->
	<xsl:template match="boxed-text">
		<xsl:variable name="data-doi" select="child::object-id[@pub-id-type='doi']/text()"/>
		
		<!-- below div commented and a new line added on 12th August, 2015
			 For the citation links, take the id from the boxed-text -->
                <xsl:choose>
                        <xsl:when test="child::object-id[@pub-id-type='doi']/text()!=''">
                                <div class="boxed-text" data-doi="{$data-doi}">
                                    <div class="boxed-text">
                                        <xsl:attribute name="id">
                                            <xsl:value-of select="@id"/>
                                        </xsl:attribute>
                                            <xsl:apply-templates/>
                                    </div>
                                </div>
                        </xsl:when>
                        <xsl:otherwise>
                                <div class="boxed-text">
                                        <xsl:apply-templates/>
                                </div>
                                
                        </xsl:otherwise>
                </xsl:choose>
                
		
		
	</xsl:template>
        
        <xsl:template match="boxed-text/label">
            <span class="boxed-text-label">
                <xsl:apply-templates/>
            </span>
            <!--<xsl:text> </xsl:text>-->
        </xsl:template>
	
	<!-- START - general format -->
	
	<!-- list elements start-->
	
	<xsl:template match="list">
		<xsl:variable name="id" select="concat('list-', count(preceding::list)+1)"/>
		<xsl:choose>
			<xsl:when test="@list-type='order'">
				<ol class="list-ord " id="{$id}">
					<xsl:apply-templates/>
				</ol>
			</xsl:when>
			<xsl:otherwise>
				<ul class="list-unord " id="{$id}">
					<xsl:apply-templates/>
				</ul>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="list/list-item">
		<li>
			<xsl:apply-templates/>
		</li>
	</xsl:template>
	
	<xsl:template match="bold">
		<strong>
			<xsl:apply-templates/>
		</strong>
	</xsl:template>
	
	<xsl:template match="italic">
		<em>
                    <xsl:apply-templates/>
		</em>
	</xsl:template>
	
	<xsl:template match="sup">
		<sup>
                    <xsl:apply-templates/>
		</sup>
	</xsl:template>
	
	<xsl:template match="sub">
		<sub>
                    <xsl:apply-templates/>
		</sub>
	</xsl:template>
	
	<!-- END - general format -->
	
	<!-- nodes to remove -->
	<xsl:template match="object-id|table-wrap/label" />
	
	
</xsl:stylesheet><!-- Stylus Studio meta-information - (c) 2004-2009. Progress Software Corporation. All rights reserved.

<metaInformation>
	<scenarios>
		<scenario default="yes" name="Scenario1" userelativepaths="yes" externalpreview="no" url="elife07370.xml" htmlbaseurl="" outputurl="elife07370.html" processortype="saxon8" useresolver="yes" profilemode="0" profiledepth="" profilelength=""
		          urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" validateoutput="no" validator="internal"
		          customvalidator="">
			<advancedProp name="sInitialMode" value=""/>
			<advancedProp name="bXsltOneIsOkay" value="true"/>
			<advancedProp name="bSchemaAware" value="true"/>
			<advancedProp name="bXml11" value="false"/>
			<advancedProp name="iValidation" value="0"/>
			<advancedProp name="bExtensions" value="true"/>
			<advancedProp name="iWhitespace" value="0"/>
			<advancedProp name="sInitialTemplate" value=""/>
			<advancedProp name="bTinyTree" value="true"/>
			<advancedProp name="xsltVersion" value="2.0"/>
			<advancedProp name="bWarnings" value="true"/>
			<advancedProp name="bUseDTD" value="false"/>
			<advancedProp name="iErrorHandling" value="fatal"/>
		</scenario>
	</scenarios>
	<MapperMetaTag>
		<MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/>
		<MapperBlockPosition></MapperBlockPosition>
		<TemplateContext></TemplateContext>
		<MapperFilter side="source"></MapperFilter>
	</MapperMetaTag>
</metaInformation>
-->
