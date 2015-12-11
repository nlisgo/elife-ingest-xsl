<xsl:stylesheet version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="xsi xs xlink mml">

    <xsl:output method="xml" indent="no" encoding="utf-8"/>

    <xsl:variable name="upperspecchars" select="'ÁÀÂÄÉÈÊËÍÌÎÏÓÒÔÖÚÙÛÜ'"/>
    <xsl:variable name="uppernormalchars" select="'AAAAEEEEIIIIOOOOUUUU'"/>
    <xsl:variable name="smallspecchars" select="'áàâäéèêëíìîïóòôöúùûü'"/>
    <xsl:variable name="smallnormalchars" select="'aaaaeeeeiiiioooouuuu'"/>
    <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
    <xsl:variable name="smallcase" select="'abcdefghijklmnopqrstuvwxyz'"/>
    <xsl:variable name="allcase" select="concat($smallcase, $uppercase)"/>

    <xsl:template match="/">
        <xsl:call-template name="metatags"/>
        <xsl:call-template name="dc-descriptions"/>
        <xsl:call-template name="cc-link"/>
        <xsl:call-template name="original-article"/>
        <xsl:call-template name="author-affiliation-details"/>
        <xsl:call-template name="author-info-correspondence"/>
        <xsl:call-template name="article-info-identification"/>
        <xsl:call-template name="article-info-history"/>
        <xsl:call-template name="main-figures"/>
        <xsl:apply-templates select="//article-meta/contrib-group/contrib[@contrib-type='editor']" mode="article-info-reviewing-editor"/>
        <xsl:apply-templates select="@* | node()"/>
    </xsl:template>

    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template name="main-figures">

    </xsl:template>

    <xsl:template name="author-info-correspondence">
        <xsl:choose>
            <xsl:when test="//author-notes/corresp">
                <div id="author-info-correspondence">
                    <ul class="fn-corresp">
                        <xsl:apply-templates select="//author-notes/corresp"/>
                    </ul>
                </div>
            </xsl:when>
            <xsl:when test="//contrib[@contrib-type='author'][@corresp='yes']//email">
                <div id="author-info-correspondence">
                    <ul class="fn-corresp">
                        <xsl:for-each select="//contrib[@contrib-type='author'][@corresp='yes']//email">
                            <li>
                                <xsl:apply-templates select="." mode="corresp"/>
                            </li>
                        </xsl:for-each>
                    </ul>
                </div>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="cc-link">
        <div id="cc-link">
            <xsl:if test="//article-meta/permissions/license[@xlink:href]">
                <xsl:value-of select="//article-meta/permissions/license/@xlink:href"/>
            </xsl:if>
        </div>
    </xsl:template>

    <xsl:template name="original-article">
        <div id="original-article">
            <xsl:if test="//history//*[@publication-type='journal']">
                <xsl:text>date=</xsl:text><xsl:value-of select="//history//*[@publication-type='journal']/year"/>
                <xsl:if test="//history//*[@publication-type='journal']/month">
                    <xsl:value-of select="concat('-', //history//*[@publication-type='journal']/month)"/>
                    <xsl:if test="//history//*[@publication-type='journal']/day">
                        <xsl:value-of select="concat('-', //history//*[@publication-type='journal']/day)"/>
                    </xsl:if>
                </xsl:if>
                <xsl:text>&#10;title=</xsl:text><xsl:apply-templates select="//history//*[@publication-type='journal']/article-title"/>
                <xsl:if test="//history//*[@publication-type='journal']/person-group">
                    <xsl:text>&#10;author=</xsl:text>
                    <xsl:for-each select="//history//*[@publication-type='journal']/person-group/*">
                        <xsl:if test="position() > 1"><xsl:text>|</xsl:text></xsl:if>
                        <xsl:choose>
                            <xsl:when test="name() = 'name'">
                                <xsl:value-of select="concat(given-names, ' ', surname)"/>
                                <xsl:if test="suffix">
                                    <xsl:value-of select="concat(' ', suffix)"/>
                                </xsl:if>
                            </xsl:when>
                            <xsl:when test="name() = 'etal'">
                                <xsl:value-of select="name()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="."/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:if>
                <xsl:if test="//history//*[@publication-type='journal']/source">
                    <xsl:text>&#10;citeas=</xsl:text>
                    <xsl:value-of disable-output-escaping="yes" select="concat('&lt;i&gt;', //history//*[@publication-type='journal']/source, '&lt;/i&gt;')"/>
                    <xsl:value-of select="concat(' ', //history//*[@publication-type='journal']/year, ';', //history//*[@publication-type='journal']/volume, ':', //history//*[@publication-type='journal']/fpage)"/>
                    <xsl:if test="//history//*[@publication-type='journal']/lpage">
                        <xsl:value-of select="concat('-', //history//*[@publication-type='journal']/lpage)"/>
                    </xsl:if>
                </xsl:if>
                <xsl:if test="//history//*[@publication-type='journal']/pub-id[@pub-id-type='doi']">
                    <xsl:text>&#10;doi=</xsl:text>
                    <xsl:value-of select="//history//*[@publication-type='journal']/pub-id[@pub-id-type='doi']"/>
                </xsl:if>
            </xsl:if>
        </div>
    </xsl:template>

    <xsl:template name="metatags">
        <div id="metatags">
            <xsl:if test="//article-meta/permissions">
                <meta name="DC.Rights">
                    <xsl:attribute name="content">
                        <xsl:value-of select="//article-meta/permissions/copyright-statement"/><xsl:text>. </xsl:text><xsl:value-of select="translate(//article-meta/permissions/license, '&#10;&#9;', '')"/>
                    </xsl:attribute>
                </meta>
            </xsl:if>
            <xsl:for-each select="//article-meta/contrib-group/contrib">
                <meta name="DC.Contributor">
                    <xsl:attribute name="content">
                        <xsl:choose>
                            <xsl:when test="name">
                                <xsl:value-of select="concat(name/given-names, ' ', name/surname)"/>
                                <xsl:if test="name/suffix">
                                    <xsl:value-of select="concat(' ', name/suffix)"/>
                                </xsl:if>
                            </xsl:when>
                            <xsl:when test="collab">
                                <xsl:value-of select="collab"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                </meta>
            </xsl:for-each>
            <xsl:for-each select="//funding-group/award-group">
                <meta name="citation_funding_source">
                    <xsl:attribute name="content">
                        <xsl:value-of select="concat('citation_funder=', .//institution, ';citation_grant_number=', award-id, ';citation_grant_recipient=')"/>
                        <xsl:value-of select="concat(principal-award-recipient/name/given-names, ' ', principal-award-recipient/name/surname)"/>
                        <xsl:for-each select="principal-award-recipient/name/suffix">
                            <xsl:value-of select="concat(' ', .)"/>
                        </xsl:for-each>
                    </xsl:attribute>
                </meta>
            </xsl:for-each>
            <xsl:for-each select="//article-meta/contrib-group/contrib[@contrib-type='author'] | //article-meta/contrib-group/contrib[@contrib-type='editor']">
                <xsl:variable name="type" select="@contrib-type"/>
                <meta name="citation_{$type}">
                    <xsl:attribute name="content">
                        <xsl:choose>
                            <xsl:when test="name">
                                <xsl:value-of select="concat(name/given-names, ' ', name/surname)"/>
                                <xsl:if test="name/suffix">
                                    <xsl:value-of select="concat(' ', name/suffix)"/>
                                </xsl:if>
                            </xsl:when>
                            <xsl:when test="collab">
                                <xsl:value-of select="collab"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                </meta>
                <xsl:for-each select="aff[not(@id)] | xref[@ref-type='aff'][@rid]">
                    <xsl:choose>
                        <xsl:when test="name() = 'aff'">
                            <xsl:for-each select="institution | email">
                                <meta name="citation_{$type}_{name()}">
                                    <xsl:attribute name="content">
                                        <xsl:value-of select="."/>
                                    </xsl:attribute>
                                </meta>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:when test="name() = 'xref'">
                            <xsl:variable name="rid" select="@rid"/>
                            <xsl:for-each select="//aff[@id=$rid]/institution | //aff[@id=$rid]/email">
                                <meta name="citation_{$type}_{name()}">
                                    <xsl:attribute name="content">
                                        <xsl:value-of select="."/>
                                    </xsl:attribute>
                                </meta>
                            </xsl:for-each>
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each>
                <xsl:if test="xref[@ref-type='corresp'][@rid]">
                    <xsl:variable name="rid" select="xref[@ref-type='corresp']/@rid"/>
                    <xsl:if test="//corresp[@id=$rid]/email">
                        <meta name="citation_{$type}_email">
                            <xsl:attribute name="content">
                                <xsl:value-of select="//corresp[@id=$rid]/email"/>
                            </xsl:attribute>
                        </meta>
                    </xsl:if>
                </xsl:if>
                <xsl:if test="contrib-id[@contrib-id-type='orcid']">
                    <meta name="citation_{$type}_orcid">
                        <xsl:attribute name="content">
                            <xsl:value-of select="contrib-id[@contrib-id-type='orcid']"/>
                        </xsl:attribute>
                    </meta>
                </xsl:if>
            </xsl:for-each>
            <xsl:for-each select="//ref-list/ref">
                <xsl:variable name="citation_journal" select="element-citation[@publication-type='journal']/source"/>
                <xsl:variable name="citation_string">
                    <xsl:if test="$citation_journal">
                        <xsl:value-of select="concat(';citation_journal_title=', $citation_journal)"/>
                    </xsl:if>
                    <xsl:for-each select=".//person-group[@person-group-type='author']/name | .//person-group[@person-group-type='author']/collab">
                        <xsl:choose>
                            <xsl:when test="name() = 'name'">
                                <xsl:value-of select="concat(';citation_author=', given-names, '. ', surname)"/>
                                <xsl:if test="suffix">
                                    <xsl:value-of select="concat(' ', suffix)"/>
                                </xsl:if>
                            </xsl:when>
                            <xsl:when test="name() = 'collab'">
                                <xsl:value-of select="concat(';citation_author=', .)"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each>
                    <xsl:for-each select=".//article-title | element-citation[not(@publication-type='journal')]/source">
                        <xsl:value-of select="concat(';citation_title=', .)"/>
                    </xsl:for-each>
                    <xsl:if test=".//fpage">
                        <xsl:value-of select="concat(';citation_pages=', .//fpage)"/>
                        <xsl:if test=".//lpage">
                            <xsl:value-of select="concat('-', .//lpage)"/>
                        </xsl:if>
                    </xsl:if>
                    <xsl:if test=".//volume">
                        <xsl:value-of select="concat(';citation_volume=', .//volume)"/>
                    </xsl:if>
                    <xsl:if test=".//year">
                        <xsl:value-of select="concat(';citation_year=', .//year)"/>
                    </xsl:if>
                    <xsl:if test=".//pub-id[@pub-id-type='doi']">
                        <xsl:value-of select="concat(';citation_doi=', .//pub-id[@pub-id-type='doi'])"/>
                    </xsl:if>
                </xsl:variable>
                <xsl:if test="string-length($citation_string)>1">
                    <meta name="citation_reference">
                        <xsl:attribute name="content">
                            <xsl:value-of select="substring-after($citation_string, ';')"/>
                        </xsl:attribute>
                    </meta>
                </xsl:if>
            </xsl:for-each>
        </div>
    </xsl:template>

    <xsl:template match="article-meta/title-group/article-title">
        <div id="article-title">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="custom-meta-group">
        <xsl:if test="custom-meta[@specific-use='meta-only']/meta-name[text()='Author impact statement']/following-sibling::meta-value">
            <div id="impact-statement">
                <xsl:apply-templates select="custom-meta[@specific-use='meta-only']/meta-name[text()='Author impact statement']/following-sibling::meta-value/node()"/>
            </div>
        </xsl:if>
    </xsl:template>

    <!-- Author list -->
    <xsl:template match="contrib-group[not(@content-type)]">
        <xsl:apply-templates/>
        <xsl:if test="contrib[@contrib-type='author'][not(@id)]">
            <div id="author-info-group-authors">
                <xsl:apply-templates select="contrib[@contrib-type='author'][not(@id)]"/>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template match="contrib[@contrib-type='author'][not(@id)]">
        <xsl:apply-templates select="collab"/>
    </xsl:template>

    <xsl:template match="contrib//collab">
        <h4 class="equal-contrib-label">
            <xsl:apply-templates/>
        </h4>
        <xsl:variable name="contrib-id">
            <xsl:apply-templates select="../contrib-id"/>
        </xsl:variable>
        <xsl:if test="../../..//contrib[@contrib-type='author non-byline']/contrib-id[text()=$contrib-id]">
            <ul>
                <xsl:for-each
                        select="../../..//contrib[@contrib-type='author non-byline']/contrib-id[text()=$contrib-id]">
                    <li>
                        <xsl:if test="position()=1">
                            <xsl:attribute name="class">
                                <xsl:value-of select="'first'"/>
                            </xsl:attribute>
                        </xsl:if>
                        <xsl:if test="position()=last()">
                            <xsl:attribute name="class">
                                <xsl:value-of select="'last'"/>
                            </xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="../name/given-names"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="../name/surname"/>
                        <xsl:text>, </xsl:text>
                        <xsl:for-each select="../aff">
                            <xsl:call-template name="collabaff"/>
                            <xsl:if test="position() != last()">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </li>
                </xsl:for-each>
            </ul>
        </xsl:if>
    </xsl:template>

    <xsl:template name="collabaff">
        <span class="aff">
            <xsl:for-each select="@* | node()">
                <xsl:choose>
                    <xsl:when test="name() = 'institution'">
                        <span class="institution">
                            <xsl:value-of select="."/>
                        </span>
                    </xsl:when>
                    <xsl:when test="name()='country'">
                        <span class="country">
                            <xsl:value-of select="."/>
                        </span>
                    </xsl:when>
                    <xsl:when test="name()='addr-line'">
                        <span class="addr-line">
                            <xsl:apply-templates mode="authorgroup"/>
                        </span>
                    </xsl:when>
                    <xsl:when test="name()=''">
                        <xsl:value-of select="."/>
                    </xsl:when>
                    <xsl:otherwise>
                        <span class="{name()}">
                            <xsl:value-of select="."/>
                        </span>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>

        </span>
    </xsl:template>

    <xsl:template match="addr-line/named-content" mode="authorgroup">
        <span class="named-content">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <!-- ==== FRONT MATTER START ==== -->

    <xsl:template match="surname | given-names | name">
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

    <!-- ==== Data set start ==== -->
    <xsl:template match="sec[@sec-type='datasets']">
        <div id="datasets">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="sec[@sec-type='datasets']/title"/>
    <xsl:template match="related-object">
        <span class="{name()}">
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="related-object/collab">
        <span class="{name()}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="related-object/name">
        <span class="name">
            <xsl:value-of select="surname"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="given-names"/>
            <xsl:if test="suffix">
                <xsl:text> </xsl:text>
                <xsl:value-of select="suffix"/>
            </xsl:if>
        </span>
    </xsl:template>
    <xsl:template match="related-object/year">
        <span class="{name()}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="related-object/source">
        <span class="{name()}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="related-object/x">
        <span class="{name()}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="related-object/etal">
        <span class="{name()}">
            <xsl:text>et al.</xsl:text>
        </span>
    </xsl:template>
    <xsl:template match="related-object/comment">
        <span class="{name()}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="related-object/object-id">
        <span class="{name()}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <!-- author-notes -->
    <xsl:template match="author-notes">
        <xsl:apply-templates/>
        <xsl:if test="fn[@fn-type='present-address']">
            <div id="author-info-additional-address">
                <ul class="additional-address-items">
                    <xsl:apply-templates select="fn[@fn-type='present-address']"/>
                </ul>
            </div>
        </xsl:if>

        <xsl:if test="fn[@fn-type='con']|fn[@fn-type='other']">
            <div id="author-info-equal-contrib">
                <xsl:apply-templates select="fn[@fn-type='con']"/>
            </div>
            <div id="author-info-other-footnotes">
                <xsl:apply-templates select="fn[@fn-type='other']"/>
            </div>
        </xsl:if>
        <div id="author-info-contributions">
            <xsl:apply-templates select="ancestor::article/back//fn-group[@content-type='author-contribution']"/>
        </div>
    </xsl:template>

    <xsl:template match="author-notes/fn[@fn-type='con']">
        <section class="equal-contrib">
            <h4 class="equal-contrib-label">
                <xsl:apply-templates/>
            </h4>
            <xsl:variable name="contriputeid">
                <xsl:value-of select="@id"/>
            </xsl:variable>
            <ul class="equal-contrib-list">
                <xsl:for-each select="../../contrib-group/contrib/xref[@rid=$contriputeid]">
                    <li>
                        <xsl:value-of select="../name/given-names"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="../name/surname"/>
                    </li>
                </xsl:for-each>
            </ul>
        </section>
    </xsl:template>

    <xsl:template match="fn-group[@content-type='author-contribution']">
        <ul class="fn-con">
            <xsl:apply-templates/>
        </ul>
    </xsl:template>

    <xsl:template match="fn-group[@content-type='author-contribution']/fn">
        <li>
            <xsl:apply-templates/>
        </li>
    </xsl:template>

    <xsl:template match="fn-group[@content-type='author-contribution']/fn/p">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="author-notes/fn[@fn-type='con']/p">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="author-notes/fn[@fn-type='other']">
        <xsl:variable name="contriputeid">
            <xsl:value-of select="@id"/>
        </xsl:variable>
        <div class="foot-note" id="{$contriputeid}">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="author-notes/fn[@fn-type='other']/p">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="author-notes/corresp">
        <li>
            <xsl:apply-templates select="email" mode="corresp"/>
        </li>
    </xsl:template>

    <xsl:template match="email" mode="corresp">
        <a>
            <xsl:attribute name="href">
                <xsl:value-of select="concat('mailto:',.)"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </a>
        <xsl:variable name="contriputeid">
            <xsl:value-of select="../@id"/>
        </xsl:variable>
        <xsl:variable name="given-names">
            <xsl:choose>
                <xsl:when test="../../../contrib-group/contrib/xref[@rid=$contriputeid][1]/../name/given-names">
                    <xsl:value-of select="../../../contrib-group/contrib/xref[@rid=$contriputeid][1]/../name/given-names"/>
                </xsl:when>
                <xsl:when test="ancestor::contrib/name/given-names">
                    <xsl:value-of select="ancestor::contrib/name/given-names"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="surname">
            <xsl:choose>
                <xsl:when test="../../../contrib-group/contrib/xref[@rid=$contriputeid][1]/../name/surname">
                    <xsl:value-of select="../../../contrib-group/contrib/xref[@rid=$contriputeid][1]/../name/surname"/>
                </xsl:when>
                <xsl:when test="ancestor::contrib/name/surname">
                    <xsl:value-of select="ancestor::contrib/name/surname"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <xsl:if test="$given-names != '' and $surname != ''">
            <xsl:text> (</xsl:text>
            <xsl:value-of select="translate($given-names, concat($smallcase, $smallspecchars, '. '), '')"/>
            <xsl:value-of select="translate($surname, concat($smallcase, $smallspecchars, '. '), '')"/>
            <xsl:text>)</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template match="author-notes/fn[@fn-type='present-address']">
        <li>
            <span class="present-address-intials">
                <xsl:variable name="contriputeid">
                    <xsl:value-of select="@id"/>
                </xsl:variable>
                <xsl:for-each select="../../contrib-group/contrib/xref[@rid=$contriputeid]">
                    <xsl:text>--</xsl:text>
                    <xsl:value-of select="translate(../name/given-names, concat($smallcase, '. '), '')"/>
                    <xsl:text>-</xsl:text>
                    <xsl:value-of select="translate(../name/surname, concat($smallcase, '. '), '')"/>
                    <xsl:text>:</xsl:text>
                </xsl:for-each>
            </span>
            <xsl:text> Present address:</xsl:text>
            <br/>
            <xsl:apply-templates/>
        </li>
    </xsl:template>

    <xsl:template match="author-notes/fn[@fn-type='present-address']/label"/>
    <xsl:template match="author-notes/fn[@fn-type='present-address']/p">
        <xsl:apply-templates/>
    </xsl:template>

    <!-- funding-group -->
    <xsl:template match="funding-group">
        <div id="author-info-funding">
            <ul class="funding-group">
                <xsl:apply-templates/>
            </ul>
            <xsl:if test="funding-statement">
                <p class="funding-statement">
                    <xsl:value-of select="funding-statement"/>
                </p>
            </xsl:if>
        </div>
    </xsl:template>
    <xsl:template match="funding-group/award-group">
        <li>
            <xsl:apply-templates/>
        </li>
    </xsl:template>
    <xsl:template match="funding-source">
        <span class="funding-source">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="funding-source/institution-wrap">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="institution">
        <span class="institution">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="award-id">
        <span class="award-id">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="principal-award-recipient">
        <span class="principal-award-recipient">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template
            match="principal-award-recipient/surname | principal-award-recipient/given-names | principal-award-recipient/name">
        <span class="name">
            <xsl:value-of select="given-names"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="surname"/>
        </span>
        <xsl:value-of select="name"/>
    </xsl:template>

    <xsl:template match="funding-statement" name="funding-statement">
        <p class="funding-statement">
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="funding-statement"/>
    <!-- fn-group -->
    <xsl:template name="article-info-identification">
        <xsl:variable name="doi" select="//article-meta/article-id[@pub-id-type='doi']"/>
        <div>
            <xsl:attribute name="id"><xsl:value-of select="'article-info-identification'"/></xsl:attribute>
            <div>
                <xsl:attribute name="class"><xsl:value-of select="'elife-article-info-doi'"/></xsl:attribute>
                <span class="info-label">DOI</span> <span class="info-content"><a href="/lookup/doi/{$doi}"><xsl:value-of select="$doi"/></a></span>
            </div>
            <div>
                <xsl:attribute name="class"><xsl:value-of select="'elife-article-info-citeas'"/></xsl:attribute>
                <span class="info-label">Cite this as</span> <span class="info-content"><xsl:call-template name="citation"/></span>
            </div>
        </div>
    </xsl:template>
    <xsl:template name="article-info-history">
        <div>
            <xsl:attribute name="id"><xsl:value-of select="'article-info-history'"/></xsl:attribute>
            <ul>
                <xsl:attribute name="class"><xsl:value-of select="'publication-history'"/></xsl:attribute>
                <xsl:for-each select="//history/date[@date-type]">
                    <xsl:apply-templates select="." mode="publication-history-item"/>
                </xsl:for-each>
                <xsl:apply-templates select="//article-meta/pub-date[@date-type]" mode="publication-history-item">
                    <xsl:with-param name="date-type" select="'published'"/>
                </xsl:apply-templates>
            </ul>
        </div>
    </xsl:template>
    <xsl:template name="author-affiliation-details">
        <div>
            <xsl:attribute name="id"><xsl:value-of select="'author-affiliation-details'"/></xsl:attribute>
            <xsl:for-each select="//article-meta//contrib-group/contrib[@contrib-type='author']">
                <div>
                    <xsl:attribute name="id"><xsl:value-of select="concat('author-affiliation-details-', position())"/></xsl:attribute>
                    <xsl:for-each select="aff[not(@id)] | xref[@ref-type='aff'][@rid]">
                        <xsl:if test="position() > 1"><xsl:text>; </xsl:text></xsl:if>
                        <xsl:choose>
                            <xsl:when test="name() = 'aff'">
                                <xsl:apply-templates select="." mode="affiliation-details"/>
                            </xsl:when>
                            <xsl:when test="name() = 'xref'">
                                <xsl:variable name="rid" select="@rid"/>
                                <xsl:apply-templates select="//aff[@id=$rid]" mode="affiliation-details"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each>
                </div>
            </xsl:for-each>
        </div>
    </xsl:template>
    <xsl:template match="date | pub-date" mode="publication-history-item">
        <xsl:param name="date-type" select="string(@date-type)"/>
        <li>
            <xsl:attribute name="class"><xsl:value-of select="$date-type"/></xsl:attribute>
            <span>
                <xsl:attribute name="class"><xsl:value-of select="concat($date-type, '-label')"/></xsl:attribute>
                <xsl:call-template name="camel-case-word"><xsl:with-param name="text" select="$date-type"/></xsl:call-template>
            </span>
            <xsl:variable name="month-long">
                <xsl:call-template name="month-long">
                    <xsl:with-param name="month"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:value-of select="concat(' ', $month-long, ' ', day, ', ', year, '.')"/>
        </li>
    </xsl:template>
    <xsl:template match="fn-group[@content-type='ethics-information']">
        <div id="article-info-ethics">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="fn-group[@content-type='ethics-information']/fn">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="fn-group[@content-type='ethics-information']/title"/>
    <xsl:template match="contrib[@contrib-type='editor']" mode="article-info-reviewing-editor">
        <div id="article-info-reviewing-editor">
            <div>
                <xsl:attribute name="class"><xsl:value-of select="'elife-article-info-reviewingeditor-text'"/></xsl:attribute>
                <xsl:apply-templates select="node()"/>
            </div>
        </div>
    </xsl:template>

    <xsl:template match="fn-group[@content-type='competing-interest']">
        <div id="author-info-competing-interest">
            <ul class="fn-conflict">
                <xsl:apply-templates/>
            </ul>
        </div>
    </xsl:template>
    <xsl:template match="fn-group[@content-type='competing-interest']/fn">
        <li>
            <xsl:apply-templates/>
        </li>
    </xsl:template>

    <!-- permissions -->
    <xsl:template match="permissions">
        <div id="article-info-license">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="permissions/copyright-statement">
        <ul class="copyright-statement">
            <li>
                <xsl:apply-templates/>
            </li>
        </ul>
    </xsl:template>

    <xsl:template match="license">
        <div class="license">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="license-p">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <!-- Affiliations -->
    <xsl:template match="aff[@id]">
        <div id="{@id}">
            <span class="aff">
                <xsl:apply-templates/>
            </span>
        </div>
    </xsl:template>

    <xsl:template match="aff" mode="affiliation-details">
        <span class="aff">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="aff/institution">
        <span class="institution">
            <xsl:if test="@content-type">
                <xsl:attribute name="data-content-type">
                    <xsl:value-of select="@content-type"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="aff/addr-line">
        <span class="addr-line">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="addr-line/named-content">
        <span class="named-content">
            <xsl:if test="@content-type">
                <xsl:attribute name="data-content-type">
                    <xsl:value-of select="@content-type"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="aff/country">
        <span class="country">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="aff/x">
        <span class="x">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="aff//bold">
        <span class="bold">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="aff//italic">
        <span class="italic">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="aff/email">
        <xsl:variable name="email">
            <xsl:apply-templates/>
        </xsl:variable>
        <!-- if parent contains more than just email then it should have a space before email -->
        <xsl:if test="string(..) != text() and not(contains(string(..), concat(' ', text())))">
            <xsl:text> </xsl:text>
        </xsl:if>
        <a href="mailto:{$email}" class="email">
            <xsl:copy-of select="$email"/>
        </a>
    </xsl:template>

    <!-- ==== FRONT MATTER END ==== -->

    <xsl:template match="abstract">
        <xsl:variable name="data-doi" select="child::object-id[@pub-id-type='doi']/text()"/>
        <div data-doi="{$data-doi}">
            <xsl:choose>
                <xsl:when test="./title">
                    <xsl:attribute name="id">
                        <xsl:value-of select="translate(translate(./title, $uppercase, $smallcase), ' ', '-')"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="id">
                        <xsl:value-of select="name(.)"/>
                    </xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <!-- Start transforming sections to heading levels -->
    <xsl:template match="supplementary-material">
        <xsl:variable name="id">
            <xsl:value-of select="@id"/>
        </xsl:variable>
        <xsl:variable name="data-doi" select="child::object-id[@pub-id-type='doi']/text()"/>
        <div class="supplementary-material" data-doi="{$data-doi}">
            <div class="supplementary-material-expansion" id="{$id}">
                <xsl:apply-templates/>
            </div>
        </div>
    </xsl:template>

    <!-- No need to proceed sec-type="additional-information", sec-type="supplementary-material" and sec-type="datasets"-->
    <xsl:template match="sec[not(@sec-type='additional-information')][not(@sec-type='datasets')][not(@sec-type='supplementary-material')]">
        <div>
            <xsl:if test="@sec-type">
                <xsl:attribute name="class">
                    <xsl:value-of select="concat('section ', ./@sec-type)"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="@*[name()!='sec-type'] | node()"/>
        </div>
    </xsl:template>

    <xsl:template match="sec[not(@sec-type='datasets')]/title | boxed-text/caption/title">
        <xsl:if test="node() != ''">
            <xsl:element name="h{count(ancestor::sec) + 2}">
                <xsl:apply-templates select="@* | node()"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template match="app//sec/title">
        <xsl:element name="h{count(ancestor::sec) + 3}">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    <!-- END transforming sections to heading levels -->

    <xsl:template match="p">
        <xsl:if test="not(supplementary-material)">
            <p>
                <xsl:if test="ancestor::caption and (count(preceding-sibling::p) = 0) and (ancestor::boxed-text or ancestor::media)">
                    <xsl:attribute name="class">
                        <xsl:value-of select="'first-child'"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:apply-templates/>
            </p>
        </xsl:if>
        <xsl:if test="supplementary-material">
            <xsl:if test="ancestor::caption and (count(preceding-sibling::p) = 0) and (ancestor::boxed-text or ancestor::media)">
                <xsl:attribute name="class">
                    <xsl:value-of select="'first-child'"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="ext-link">
        <xsl:if test="@ext-link-type = 'uri'">
            <a>
                <xsl:attribute name="href">
                    <xsl:choose>
                        <xsl:when test="starts-with(@xlink:href, 'www.')">
                            <xsl:value-of select="concat('http://', @xlink:href)"/>
                        </xsl:when>
                        <xsl:when test="starts-with(@xlink:href, 'doi:')">
                            <xsl:value-of select="concat('http://dx.doi.org/', substring-after(@xlink:href, 'doi:'))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="@xlink:href"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:attribute name="target"><xsl:value-of select="'_blank'"/></xsl:attribute>
                <xsl:apply-templates/>
            </a>
        </xsl:if>
        <xsl:if test="@ext-link-type = 'doi'">
            <a>
                <xsl:attribute name="href">
                    <xsl:choose>
                        <xsl:when test="starts-with(@xlink:href, '10.7554/')">
                            <xsl:value-of select="concat('/lookup/doi/', @xlink:href)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat('http://dx.doi.org/', @xlink:href)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:apply-templates/>
            </a>
        </xsl:if>
    </xsl:template>

    <!-- START handling citation objects -->
    <xsl:template match="xref">
        <xsl:choose>
            <xsl:when test="ancestor::fn">
                <span class="xref-table">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <a>
                    <xsl:attribute name="class">
                        <xsl:value-of select="concat('xref-', ./@ref-type)"/>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                        <!-- If xref has multiple elements in rid, then the link should points to 1st -->
                        <xsl:choose>
                            <xsl:when test="contains(@rid, ' ')">
                                <xsl:value-of select="concat('#',substring-before(@rid, ' '))"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="concat('#',@rid)"/>
                            </xsl:otherwise>
                        </xsl:choose>

                    </xsl:attribute>
                    <xsl:apply-templates/>
                </a>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- END handling citation objects -->

    <!-- START Table Handling -->
    <xsl:template match="table-wrap">
        <xsl:variable name="data-doi" select="child::object-id[@pub-id-type='doi']/text()"/>
        <div class="table-wrap" data-doi="{$data-doi}">
            <xsl:apply-templates select="." mode="testing"/>
        </div>
    </xsl:template>

    <xsl:template match="table-wrap/label" mode="captionLabel">
        <span class="table-label">
            <xsl:apply-templates/>
        </span>
        <xsl:text> </xsl:text>
    </xsl:template>

    <xsl:template match="caption">
        <xsl:choose>
            <!-- if article-title exists, make it as title.
                     Otherwise, make source -->
            <xsl:when test="parent::table-wrap">
                <xsl:if test="following-sibling::graphic">
                    <xsl:variable name="caption" select="parent::table-wrap/label/text()"/>
                    <xsl:variable name="graphics" select="following-sibling::graphic/@xlink:href"/>
                    <div class="fig-inline-img">
                        <a href="[graphic-{$graphics}-large]" class="figure-expand-popup" title="{$caption}">
                            <img data-img="[graphic-{$graphics}-small]" src="[graphic-{$graphics}-medium]" alt="{$caption}"/>
                        </a>
                    </div>
                </xsl:if>
                <div class="table-caption">
                    <xsl:apply-templates select="parent::table-wrap/label" mode="captionLabel"/>
                    <xsl:apply-templates/>
                    <div class="sb-div caption-clear"></div>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="table-wrap/table">
        <table>
            <xsl:apply-templates/>
        </table>
    </xsl:template>

    <!-- Handle other parts of table -->
    <xsl:template match="thead | tr">
        <xsl:copy>
            <xsl:if test="@style">
                <xsl:attribute name="style">
                    <xsl:value-of select="@style"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="tbody">
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="th | td">
        <xsl:copy>
            <xsl:if test="@rowspan">
                <xsl:attribute name="rowspan">
                    <xsl:value-of select="@rowspan"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@colspan">
                <xsl:attribute name="colspan">
                    <xsl:value-of select="@colspan"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@align">
                <xsl:attribute name="class">
                    <xsl:value-of select="concat('table-', @align)"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <!-- Handle Table FootNote -->
    <xsl:template match="table-wrap-foot">
        <div class="table-foot">
            <ul class="table-footnotes">
                <xsl:apply-templates/>
            </ul>
        </div>
    </xsl:template>

    <xsl:template match="table-wrap-foot/fn">
        <li class="fn">
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </li>
    </xsl:template>

    <xsl:template match="named-content">
        <span>
            <xsl:attribute name="class">
                <xsl:value-of select="name()"/>
                <xsl:if test="@content-type">
                    <xsl:value-of select="concat(' ', @content-type)"/>
                </xsl:if>
            </xsl:attribute>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template match="inline-formula">
        <span class="inline-formula">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="disp-formula">
        <span class="disp-formula">
            <xsl:if test="@id">
                <xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
            <xsl:if test="label">
                <span class="disp-formula-label">
                    <xsl:value-of select="label/text()"/>
                </span>
            </xsl:if>
        </span>
    </xsl:template>

    <xsl:template match="*[local-name()='math']">
        <span class="mathjax mml-math">
            <xsl:text disable-output-escaping="yes">&lt;math xmlns="http://www.w3.org/1998/Math/MathML"&gt;</xsl:text>
            <xsl:apply-templates/>
            <xsl:text disable-output-escaping="yes">&lt;/math&gt;</xsl:text>
        </span>
    </xsl:template>

    <!-- END Table Handling -->

    <!-- Start Figure Handling -->
    <!-- fig with atrtribute specific-use are supplement figures -->

    <!-- NOTE: PATH/LINK to be replaced -->
    <xsl:template match="fig-group">
        <!-- set main figure's DOI -->
        <xsl:variable name="data-doi" select="child::fig[1]/object-id[@pub-id-type='doi']/text()"/>
        <div class="fig-group" id="{concat('fig-group-', count(preceding::fig-group)+1)}" data-doi="{$data-doi}">
            <xsl:apply-templates select="." mode="testing"/>
        </div>
    </xsl:template>

    <xsl:template name="dc-descriptions">
        <div id="dc-description">
            <xsl:if test="//abstract[@abstract-type='executive-summary'] | //abstract[not(@abstract-type)]">
                <xsl:variable name="dc-description-digest">
                    <xsl:choose>
                        <xsl:when test="//abstract[@abstract-type='executive-summary']">
                            <xsl:for-each select="//abstract[@abstract-type='executive-summary']/p">
                                <xsl:if test="not(ext-link[@ext-link-type='doi'])">
                                    <xsl:value-of select="concat(' ', .)"/>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:for-each select="//abstract[not(@abstract-type)]/p">
                                <xsl:if test="not(ext-link[@ext-link-type='doi'])">
                                    <xsl:value-of select="concat(' ', .)"/>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:value-of select="substring-after($dc-description-digest, ' ')"/>
            </xsl:if>
        </div>
        <xsl:for-each select="//fig | //table-wrap | //boxed-text | //supplementary-material | //media[not(@mimetype='application')]">
            <xsl:if test="object-id[@pub-id-type='doi']">
                <xsl:variable name="data-doi" select="object-id[@pub-id-type='doi']/text()"/>
                <xsl:apply-templates select="." mode="dc-description">
                    <xsl:with-param name="doi" select="$data-doi"/>
                </xsl:apply-templates>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="fig | table-wrap | boxed-text | supplementary-material | media" mode="dc-description">
        <xsl:param name="doi"/>
        <xsl:variable name="data-dc-description">
            <xsl:if test="caption/title">
                <xsl:value-of select="concat(' ', caption/title)"/>
            </xsl:if>
            <xsl:for-each select="caption/p">
                <xsl:if test="not(ext-link[@ext-link-type='doi']) and not(.//object-id[@pub-id-type='doi'])">
                    <xsl:value-of select="concat(' ', .)"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <div data-dc-description="{$doi}">
            <xsl:value-of select="substring-after($data-dc-description, ' ')"/>
        </div>
    </xsl:template>

    <!-- individual fig in fig-group -->

    <xsl:template match="fig">
        <xsl:variable name="data-doi" select="child::object-id[@pub-id-type='doi']/text()"/>
        <div class="fig" data-doi="{$data-doi}">
            <xsl:apply-templates select="." mode="testing"/>
        </div>
    </xsl:template>

    <!-- fig caption -->
    <xsl:template match="fig//caption">
        <xsl:variable name="graphic-type">
            <xsl:choose>
                <xsl:when test="starts-with(../label/text(), 'Animation')">
                    <xsl:value-of select="'animation'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'graphic'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="not(parent::supplementary-material)">
                <div class="fig-caption">
                    <xsl:variable name="graphics" select="../graphic/@xlink:href"/>
                    <!-- three options -->
                    <span class="elife-figure-links">
                        <span class="elife-figure-link elife-figure-link-download">
                            <a href="[{$graphic-type}-{$graphics}-download]"><xsl:attribute name="download"/>Download figure</a>
                        </span>
                        <span class="elife-figure-link elife-figure-link-newtab">
                            <a href="[{$graphic-type}-{$graphics}-large]" target="_blank">Open in new tab</a>
                        </span>
                    </span>
                    <span class="fig-label">
                        <xsl:value-of select="../label/text()"/>
                    </span>
                    <xsl:text> </xsl:text>
                    <xsl:apply-templates/>
                    <div class="sb-div caption-clear"></div>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="../label" mode="supplementary-material"/>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="supplementary-material/label">
        <xsl:apply-templates select="." mode="supplementary-material"/>
    </xsl:template>

    <xsl:template match="label" mode="supplementary-material">
        <span class="supplementary-material-label">
            <xsl:value-of select="."/>
        </span>
    </xsl:template>

    <xsl:template match="fig//caption/title | supplementary-material/caption/title">
        <span class="caption-title">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="fig//ext-link">
        <xsl:if test="ancestor::supplementary-material or @ext-link-type='doi'">
            <a href="/lookup/doi/{@xlink:href}">
                <xsl:apply-templates/>
            </a>
        </xsl:if>
        <xsl:if test="not(ancestor::supplementary-material) and @ext-link-type!='doi'">
            <a href="{@xlink:href}">
                <xsl:apply-templates/>
            </a>
        </xsl:if>
    </xsl:template>

    <!-- END Figure Handling -->

    <!-- body content -->
    <xsl:template match="body">
        <div class="elife-article-decision-letter">
            <xsl:apply-templates/>
        </div>
        <div id='main-text'>
            <div class="article fulltext-view">
                <xsl:apply-templates mode="testing"/>
                <xsl:call-template name="appendices-main-text"/>
            </div>
        </div>
        <div id="main-figures">
            <xsl:for-each select=".//fig[not(@specific-use)]">
                <xsl:apply-templates select="."/>
            </xsl:for-each>
        </div>
    </xsl:template>

    <xsl:template
            match="sec[not(@sec-type='additional-information')][not(@sec-type='datasets')][not(@sec-type='supplementary-material')]"
            mode="testing">
        <div>
            <xsl:if test="@sec-type">
                <xsl:attribute name="class">
                    <xsl:value-of select="concat('section ', translate(./@sec-type, '|', '-'))"/>
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
            <xsl:apply-templates mode="testing"/>
        </div>
    </xsl:template>

    <xsl:template match="p" mode="testing">
        <xsl:if test="not(supplementary-material)">
            <p>
                <xsl:if test="ancestor::caption and (count(preceding-sibling::p) = 0) and (ancestor::boxed-text or ancestor::media)">
                    <xsl:attribute name="class">
                        <xsl:value-of select="'first-child'"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:apply-templates mode="testing"/>
            </p>
        </xsl:if>
        <xsl:if test="supplementary-material">
            <xsl:if test="ancestor::caption and (count(preceding-sibling::p) = 0) and (ancestor::boxed-text or ancestor::media)">
                <xsl:attribute name="class">
                    <xsl:value-of select="'first-child'"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="xref" mode="testing">
        <xsl:choose>
            <xsl:when test="ancestor::fn">
                <span class="xref-table">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <a>
                    <xsl:attribute name="class">
                        <xsl:value-of select="concat('xref-', ./@ref-type)"/>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                        <!-- If xref has multiple elements in rid, then the link should points to 1st -->
                        <xsl:choose>
                            <xsl:when test="contains(@rid, ' ')">
                                <xsl:value-of select="concat('#',substring-before(@rid, ' '))"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="concat('#',@rid)"/>
                            </xsl:otherwise>
                        </xsl:choose>

                    </xsl:attribute>
                    <xsl:apply-templates/>
                </a>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="table-wrap" mode="testing">
        <div class="table-expansion">
            <xsl:if test="@id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="boxed-text" mode="testing">
        <!-- For the citation links, take the id from the boxed-text -->
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
                <div>
                    <xsl:attribute name="class">
                        <xsl:value-of select="'boxed-text'"/>
                        <xsl:if test="//article/@article-type != 'research-article' and .//inline-graphic">
                            <xsl:value-of select="' insight-image'"/>
                        </xsl:if>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="fig" mode="testing">
        <xsl:variable name="caption" select="child::label/text()"/>
        <xsl:variable name="id">
            <xsl:value-of select="@id"/>
        </xsl:variable>
        <xsl:variable name="graphic-type">
            <xsl:choose>
                <xsl:when test="starts-with($caption, 'Animation')">
                    <xsl:value-of select="'animation'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'graphic'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="graphics" select="child::graphic/@xlink:href"/>
        <div id="{$id}" class="fig-inline-img-set">
            <div class="elife-fig-image-caption-wrapper">
                <div class="fig-expansion">
                    <div class="fig-inline-img">
                        <a href="[{$graphic-type}-{$graphics}-large]" class="figure-expand-popup" title="{$caption}">
                            <img data-img="[{$graphic-type}-{$graphics}-small]" src="[{$graphic-type}-{$graphics}-medium]" alt="{$caption}"/>
                        </a>
                    </div>
                    <xsl:apply-templates/>
                </div>
            </div>
        </div>
    </xsl:template>

    <xsl:template match="fig-group" mode="testing">
        <!-- set main figure's DOI -->
        <div class="fig-inline-img-set-carousel">
            <div class="elife-fig-slider-wrapper">
                <div class="elife-fig-slider">
                    <div class="elife-fig-slider-img elife-fig-slider-primary">
                        <!-- use variables to set src and alt -->
                        <xsl:variable name="primaryid" select="concat('#', child::fig[not(@specific-use)]/@id)"/>
                        <xsl:variable name="primarycap" select="child::fig[not(@specific-use)]//label/text()"/>
                        <xsl:variable name="graphichref" select="child::fig[not(@specific-use)]/graphic/@xlink:href"/>
                        <a href="{$primaryid}">
                            <img src="[graphic-{$graphichref}-small]" alt="{$primarycap}"/>
                        </a>
                    </div>
                    <div class="figure-carousel-inner-wrapper">
                        <div class="figure-carousel">
                            <xsl:for-each select="child::fig[@specific-use]">
                                <!-- use variables to set src and alt -->
                                <xsl:variable name="secondarycap" select="child::label/text()"/>
                                <xsl:variable name="secgraphichref" select="child::graphic/@xlink:href"/>
                                <div class="elife-fig-slider-img elife-fig-slider-secondary">
                                    <a href="#{@id}">
                                        <img src="[graphic-{$secgraphichref}-small]" alt="{$secondarycap}"/>
                                    </a>
                                </div>
                            </xsl:for-each>
                        </div>
                    </div>
                </div>
            </div>
            <div class="elife-fig-image-caption-wrapper">
                <xsl:apply-templates/>
            </div>
        </div>
    </xsl:template>

    <xsl:template match="media" mode="testing">
        <xsl:choose>
            <xsl:when test="@mimetype != 'video'">
                <xsl:variable name="media-download-href"><xsl:value-of select="concat(substring-before(@xlink:href, '.'), '-download.', substring-after(@xlink:href, '.'))"/></xsl:variable>
                <!-- if mimetype is application -->
                <span class="inline-linked-media-wrapper">
                    <a href="[media-{$media-download-href}]">
                        <xsl:attribute name="download"/>
                        <i class="icon-download-alt"></i>
                        Download source data<span class="inline-linked-media-filename">
                            [<xsl:value-of
                                select="translate(translate(preceding-sibling::label, $uppercase, $smallcase), ' ', '-')"/>media-<xsl:value-of
                                select="count(preceding::media[@mimetype = 'application']) + 1"/>.<xsl:value-of
                                select="substring-after(@xlink:href, '.')"/>]
                        </span>
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
                                    <a href="[video-{@id}-download]"><xsl:attribute name="download"/>Download Video</a>

                                </span>
                            </div>
                        </div>
                    </div>
                    <xsl:apply-templates/>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- Acknowledgement -->

    <xsl:template match="ack">
        <div id="ack-1">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <!-- START Reference Handling -->

    <xsl:template match="ref-list">
        <div id="references">
            <ol class="elife-reflinks-links">
                <xsl:apply-templates/>
            </ol>
        </div>
    </xsl:template>

    <xsl:template match="ref">
        <li class="elife-reflinks-reflink" id="{@id}">
            <xsl:apply-templates/>
        </li>
    </xsl:template>

    <xsl:template match="ref/element-citation">
        <xsl:variable name="href">
            <xsl:choose>
                <xsl:when test="pub-id">
                    <xsl:value-of select="concat('http://dx.doi.org/', pub-id)"/>
                </xsl:when>
                <xsl:when test=".//ext-link/@xlink:href">
                    <xsl:value-of select=".//ext-link/@xlink:href"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="hreftext">
            <xsl:choose>
                <xsl:when test="pub-id">
                    <xsl:value-of select="concat('http://dx.doi.org/', pub-id)"/>
                </xsl:when>
                <xsl:when test=".//ext-link/@xlink:href = concat('http://dx.doi.org/', .//ext-link)">
                    <xsl:value-of select=".//ext-link/@xlink:href"/>
                </xsl:when>
                <xsl:when test=".//ext-link">
                    <xsl:value-of select=".//ext-link"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="title">
            <xsl:choose>
                <xsl:when test="child::article-title">
                    <xsl:apply-templates select="child::article-title/node()"/>
                </xsl:when>
                <xsl:when test="child::source">
                    <xsl:apply-templates select="child::source/node()"/>
                </xsl:when>
                <xsl:when test="child::comment">
                    <xsl:apply-templates select="child::comment/node()"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="title-type">
            <xsl:choose>
                <xsl:when test="child::article-title">
                    <xsl:value-of select="'article-title'"/>
                </xsl:when>
                <xsl:when test="child::source">
                    <xsl:value-of select="'source'"/>
                </xsl:when>
                <xsl:when test="child::comment">
                    <xsl:value-of select="'comment'"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <div class="elife-reflink-main">
            <cite class="elife-reflink-title">
                <xsl:choose>
                    <xsl:when test="$href != ''">
                        <a href="{$href}" target="_blank">
                            <span class="nlm-{$title-type}">
                                <xsl:copy-of select="$title"/>
                            </span>
                        </a>
                    </xsl:when>
                    <xsl:otherwise>
                        <span class="nlm-{$title-type}">
                            <xsl:copy-of select="$title"/>
                        </span>
                    </xsl:otherwise>
                </xsl:choose>
            </cite>

            <!-- call authors template -->

            <xsl:if test="person-group[@person-group-type='author']">
                <div class="elife-reflink-authors">
                    <xsl:for-each select="person-group[@person-group-type='author']">
                        <xsl:for-each select="name | collab">
                            <xsl:if test="position() != 1">
                                <xsl:text>, </xsl:text>
                            </xsl:if>
                            <xsl:choose>
                                <xsl:when test="name() = 'name'">
                                    <xsl:variable name="givenname" select="given-names"/>
                                    <xsl:variable name="surname" select="surname"/>
                                    <xsl:variable name="suffix" select="suffix"/>
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
                                    <xsl:variable name="hrefvalue" select="concat('http://scholar.google.com/scholar?q=&quot;author:', $fullname, '&quot;')"/>
                                    <span class="elife-reflink-author">
                                        <a href="{$hrefvalue}" target="_blank">
                                            <xsl:value-of select="$fullname"/>
                                        </a>
                                    </span>
                                </xsl:when>
                                <xsl:when test="name() = 'collab'">
                                    <span class="elife-reflink-author">
                                        <span class="nlm-collab">
                                            <xsl:apply-templates/>
                                        </span>
                                    </span>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:for-each>
                        <xsl:if test="etal">
                            <xsl:text> et al. </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </div>
            </xsl:if>

            <!-- move all other elements into details div
                and comma separate
            -->
            <xsl:variable name="class">
                <xsl:if test="@publication-type">
                    <xsl:value-of select="'elife-reflink-details-journal'"/>
                </xsl:if>
            </xsl:variable>
            <xsl:variable name="includes">
                <xsl:if test="child::article-title and child::source">
                    <xsl:value-of select="'source|'"/>
                </xsl:if>
                <xsl:if test="child::publisher-name">
                    <xsl:value-of select="'publisher-name|'"/>
                </xsl:if>
                <xsl:if test="child::publisher-loc">
                    <xsl:value-of select="'publisher-loc|'"/>
                </xsl:if>
                <xsl:if test="child::volume">
                    <xsl:value-of select="'volume|'"/>
                </xsl:if>
                <xsl:if test="child::fpage">
                    <xsl:value-of select="'fpage|'"/>
                </xsl:if>
                <xsl:if test="child::lpage">
                    <xsl:value-of select="'lpage|'"/>
                </xsl:if>
                <xsl:if test="child::year">
                    <xsl:value-of select="'year|'"/>
                </xsl:if>
            </xsl:variable>
            <div class="elife-reflink-details">
                <xsl:if test="contains($includes, 'source|')">
                    <span>
                        <xsl:if test="$class != ''">
                            <xsl:attribute name="class"><xsl:value-of select="$class"/></xsl:attribute>
                        </xsl:if>
                        <span class="nlm-source">
                            <xsl:apply-templates select="child::source/node()"/>
                        </span>
                    </span>
                </xsl:if>
                <xsl:if test="contains($includes, 'publisher-name|')">
                    <xsl:if test="not(starts-with($includes, 'publisher-name|'))">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                    <span class="elife-reflink-details-pub-name">
                        <span class="nlm-publisher-name">
                            <xsl:apply-templates select="child::publisher-name/node()"/>
                        </span>
                    </span>
                </xsl:if>
                <xsl:if test="contains($includes, 'publisher-loc|')">
                    <xsl:if test="not(starts-with($includes, 'publisher-loc|'))">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                    <span class="elife-reflink-details-pub-loc">
                        <span class="nlm-publisher-loc">
                            <xsl:apply-templates select="child::publisher-loc/node()"/>
                        </span>
                    </span>
                </xsl:if>
                <xsl:if test="contains($includes, 'volume|')">
                    <xsl:if test="not(starts-with($includes, 'volume|'))">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                    <span class="elife-reflink-details-volume">
                        <xsl:apply-templates select="child::volume/node()"/>
                    </span>
                </xsl:if>
                <xsl:if test="contains($includes, 'fpage|')">
                    <xsl:if test="not(starts-with($includes, 'fpage|'))">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                    <span class="elife-reflink-details-pages">
                        <xsl:apply-templates select="child::fpage/node()"/>
                        <xsl:if test="contains($includes, 'lpage|')">
                            <xsl:text>-</xsl:text>
                            <xsl:apply-templates select="child::lpage/node()"/>
                        </xsl:if>
                    </span>
                </xsl:if>
                <xsl:if test="contains($includes, 'year|')">
                    <xsl:if test="not(starts-with($includes, 'year|'))">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                    <span class="elife-reflink-details-year">
                        <xsl:apply-templates select="child::year/node()"/>
                    </span>
                </xsl:if>

                <xsl:if test="$href != '' and $hreftext != ''">
                    <div class="elife-reflink-doi-cited-wrapper">
                        <span>
                            <xsl:attribute name="class">
                                <xsl:choose>
                                    <xsl:when test="pub-id">
                                        <xsl:value-of select="'elife-reflink-details-doi'"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="'elife-reflink-details-uri'"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                            <a href="{$href}" target="_blank"><xsl:value-of select="$hreftext"/></a>
                        </span>
                    </div>
                </xsl:if>

            </div>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <!-- START video handling -->

    <xsl:template match="media">
        <xsl:variable name="data-doi" select="child::object-id[@pub-id-type='doi']/text()"/>
        <xsl:choose>
            <xsl:when test="@mimetype = 'video'">
                <div class="media" data-doi="{$data-doi}">
                    <xsl:apply-templates select="." mode="testing"/>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="." mode="testing"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- media caption -->
    <xsl:template match="media/caption">
        <div class="media-caption">
            <span class="media-label">
                <xsl:value-of select="preceding-sibling::label"/>
            </span>
            <xsl:text> </xsl:text>

            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="media/caption/title">
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
            <xsl:apply-templates/>

        </div>
        <div class="panel-separator"></div>
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
            <strong>DOI:</strong>
            <xsl:text> </xsl:text>

            <xsl:variable name="doino" select="preceding-sibling::*//article-id"/>
            <a>
                <xsl:attribute name="href">
                    <xsl:value-of select="concat('/lookup/doi/', $doino)"/>
                </xsl:attribute>
                <xsl:value-of select="concat('http://dx.doi.org/', $doino)"/>
            </a>
        </div>
    </xsl:template>

    <!-- START sub-article author contrib information -->

    <xsl:template match="sub-article//contrib-group">
        <div class="elife-article-editors">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="sub-article//contrib-group/contrib">
        <div>
            <xsl:attribute name="class">
                <xsl:value-of select="concat('elife-article-decision-reviewing', @contrib-type)"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="contrib[@contrib-type='editor']/name/given-names | contrib[@contrib-type='editor']/name/surname">
        <span class="nlm-given-names">
            <xsl:value-of select="given-names"/>
        </span>
        <xsl:text> </xsl:text>
        <span class="nlm-surname">
            <xsl:value-of select="surname"/>
        </span>
        <xsl:if test="parent::suffix">
            <xsl:text> </xsl:text>
            <span class="nlm-surname">
                <xsl:value-of select="parent::suffix"/>
            </span>
        </xsl:if>
        <xsl:text>, </xsl:text>
    </xsl:template>

    <xsl:template match="contrib[@contrib-type='editor']//aff">
        <xsl:apply-templates select="child::*"/>
    </xsl:template>

    <xsl:template match="contrib[@contrib-type='editor']//role | contrib[@contrib-type='editor']//institution | contrib[@contrib-type='editor']//country">
        <span class="nlm-{name()}">
            <xsl:apply-templates/>
        </span>
        <xsl:if test="not(parent::aff) or (parent::aff and following-sibling::*)">
            <xsl:text>, </xsl:text>
        </xsl:if>
    </xsl:template>

    <!-- END sub-article author contrib information -->

    <!-- box text -->
    <xsl:template match="boxed-text">
        <xsl:variable name="data-doi" select="child::object-id[@pub-id-type='doi']/text()"/>
        <xsl:choose>
            <xsl:when test="$data-doi != ''">
                <div class="boxed-text">
                    <xsl:attribute name="data-doi">
                        <xsl:value-of select="$data-doi"/>
                    </xsl:attribute>
                    <xsl:apply-templates select="." mode="testing"/>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="." mode="testing"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="boxed-text/label">
        <span class="boxed-text-label">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="inline-graphic">
        <xsl:variable name="ig-variant">
            <xsl:choose>
                <xsl:when test="//article/@article-type = 'research-article'">
                    <xsl:value-of select="'research-'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'nonresearch-'"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="ancestor::boxed-text">
                    <xsl:value-of select="'box'"/>
                </xsl:when>
                <xsl:when test="ancestor::fig">
                    <xsl:value-of select="'fig'"/>
                </xsl:when>
                <xsl:when test="ancestor::table-wrap">
                    <xsl:value-of select="'table'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'other'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        [inline-graphic-<xsl:value-of select="@xlink:href"/>-<xsl:value-of select="$ig-variant"/>]
    </xsl:template>

    <xsl:template name="appendices-main-text">
        <xsl:apply-templates select="//back/app-group/app" mode="testing"/>
    </xsl:template>

    <xsl:template match="app" mode="testing">
        <div class="section app">
            <xsl:if test="@id">
                <xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="title">
                <h3><xsl:value-of select="title"/></h3>
            </xsl:if>
            <xsl:apply-templates mode="testing"/>
        </div>
    </xsl:template>

    <!-- START - general format -->

    <!-- list elements start-->

    <xsl:template match="list">
        <xsl:choose>
            <xsl:when test="@list-type = 'simple' or @list-type = 'bullet'">
                <ul>
                    <xsl:attribute name="class">
                        <xsl:choose>
                            <xsl:when test="@list-type = 'simple'">
                                <xsl:value-of select="'list-simple'"/>
                            </xsl:when>
                            <xsl:when test="@list-type = 'bullet'">
                                <xsl:value-of select="'list-unord'"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </ul>
            </xsl:when>
            <xsl:otherwise>
                <ol>
                    <xsl:attribute name="class">
                        <xsl:choose>
                            <xsl:when test="@list-type = 'order'">
                                <xsl:value-of select="'list-ord'"/>
                            </xsl:when>
                            <xsl:when test="@list-type = 'roman-lower'">
                                <xsl:value-of select="'list-romanlower'"/>
                            </xsl:when>
                            <xsl:when test="@list-type = 'roman-upper'">
                                <xsl:value-of select="'list-romanupper'"/>
                            </xsl:when>
                            <xsl:when test="@list-type = 'alpha-lower'">
                                <xsl:value-of select="'list-alphalower'"/>
                            </xsl:when>
                            <xsl:when test="@list-type = 'alpha-upper'">
                                <xsl:value-of select="'list-alphaupper'"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </ol>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="list-item">
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

    <xsl:template match="disp-quote">
        <xsl:text disable-output-escaping="yes">&lt;blockquote class="disp-quote"&gt;</xsl:text>
            <xsl:apply-templates/>
        <xsl:text disable-output-escaping="yes">&lt;/blockquote&gt;</xsl:text>
    </xsl:template>
    
    <!-- END - general format -->

    <xsl:template match="sub-article//title-group | sub-article/front-stub | fn-group[@content-type='competing-interest']/fn/p | //history//*[@publication-type='journal']/article-title">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="caption | table-wrap/table | table-wrap-foot | fn | bold | italic | sub | sup | sec/title | ext-link | app/title | disp-formula | list | list-item | disp-quote" mode="testing">
        <xsl:apply-templates select="."/>
    </xsl:template>

    <!-- nodes to remove -->
    <xsl:template match="aff/label"/>
    <xsl:template match="disp-formula/label"/>
    <xsl:template match="app/title"/>
    <xsl:template match="fn-group[@content-type='competing-interest']/title"/>
    <xsl:template match="permissions/copyright-year | permissions/copyright-holder"/>
    <xsl:template match="fn-group[@content-type='author-contribution']/title"/>
    <xsl:template match="author-notes/fn[@fn-type='con']/label"/>
    <xsl:template match="author-notes/fn[@fn-type='other']/label"/>
    <xsl:template match="author-notes/corresp/label"/>
    <xsl:template match="abstract/title"/>
    <xsl:template match="fig/graphic"/>
    <xsl:template match="fig-group//object-id | fig-group//graphic | fig//label"/>
    <xsl:template match="ack/title"/>
    <xsl:template match="ref-list/title"/>
    <xsl:template match="ref//year | ref//article-title | ref//fpage | ref//volume | ref//source | ref//pub-id | ref//lpage | ref//comment | ref//supplement | ref//person-group[@person-group-type='editor'] | ref//edition | ref//publisher-loc | ref//publisher-name | ref//ext-link"/>
    <xsl:template match="person-group[@person-group-type='author']"/>
    <xsl:template match="media/label"/>
    <xsl:template match="sub-article//article-title"/>
    <xsl:template match="sub-article//article-id"/>
    <xsl:template match="object-id | table-wrap/label"/>
    <xsl:template match="funding-group//institution-wrap/institution-id"/>
    <xsl:template match="table-wrap/graphic"/>

    <xsl:template name="camel-case-word">
        <xsl:param name="text"/>
        <xsl:value-of select="translate(substring($text, 1, 1), $smallcase, $uppercase)" /><xsl:value-of select="translate(substring($text, 2, string-length($text)-1), $uppercase, $smallcase)" />
    </xsl:template>

    <xsl:template name="month-long">
        <xsl:param name="month"/>
        <xsl:variable name="month-int" select="number(month)"/>
        <xsl:choose>
            <xsl:when test="$month-int = 1">
                <xsl:value-of select="'January'"/>
            </xsl:when>
            <xsl:when test="$month-int = 2">
                <xsl:value-of select="'February'"/>
            </xsl:when>
            <xsl:when test="$month-int = 3">
                <xsl:value-of select="'March'"/>
            </xsl:when>
            <xsl:when test="$month-int = 4">
                <xsl:value-of select="'April'"/>
            </xsl:when>
            <xsl:when test="$month-int = 5">
                <xsl:value-of select="'May'"/>
            </xsl:when>
            <xsl:when test="$month-int = 6">
                <xsl:value-of select="'June'"/>
            </xsl:when>
            <xsl:when test="$month-int = 7">
                <xsl:value-of select="'July'"/>
            </xsl:when>
            <xsl:when test="$month-int = 8">
                <xsl:value-of select="'August'"/>
            </xsl:when>
            <xsl:when test="$month-int = 9">
                <xsl:value-of select="'September'"/>
            </xsl:when>
            <xsl:when test="$month-int = 10">
                <xsl:value-of select="'October'"/>
            </xsl:when>
            <xsl:when test="$month-int = 11">
                <xsl:value-of select="'November'"/>
            </xsl:when>
            <xsl:when test="$month-int = 12">
                <xsl:value-of select="'December'"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="citation">
        <xsl:variable name="year"><xsl:call-template name="year"/></xsl:variable>
        <xsl:variable name="volume"><xsl:call-template name="volume"/></xsl:variable>
        <xsl:value-of select="concat(//journal-meta/journal-title-group/journal-title, ' ', $year, ';', $volume, ':', //article-meta/elocation-id)"/>
    </xsl:template>

    <xsl:template name="year">
        <xsl:choose>
            <xsl:when test="//article-meta/pub-date[@date-type='pub']/year">
                <xsl:value-of select="//article-meta/pub-date[@date-type='pub']/year"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="//article-meta/permissions/copyright-year"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="volume">
        <xsl:variable name="value">
            <xsl:choose>
                <xsl:when test="//article-meta/volume">
                    <xsl:value-of select="//article-meta/volume"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="year"><call-template name="year"/></xsl:variable>
                    <xsl:value-of select="$year - 2011"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="$value"/>
    </xsl:template>

</xsl:stylesheet>
