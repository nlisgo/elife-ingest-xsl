<xsl:stylesheet version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="xsi xs xlink mml">

    <xsl:output method="xml" indent="no" encoding="utf-8"/>

    <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
    <xsl:variable name="smallcase" select="'abcdefghijklmnopqrstuvwxyz'"/>
    <xsl:variable name="allcase" select="concat($smallcase, $uppercase)"/>

    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
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

    <xsl:template match="collab">
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

    <!-- author-notes -->
    <xsl:template match="author-notes">
        <xsl:apply-templates/>
        <xsl:if test="corresp">
            <div id="author-info-correspondence">
                <ul class="fn-corresp">
                    <xsl:apply-templates select="corresp"/>
                </ul>
            </div>
        </xsl:if>
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
            <div id="author-info-contributions">
                <xsl:apply-templates select="ancestor::article/back/sec/fn-group[@content-type='author-contribution']"/>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template match="author-notes/fn[@fn-type='con']">
        <h4 class="equal-contrib-label">
            <xsl:apply-templates/>
        </h4>
        <xsl:variable name="contriputeid">
            <xsl:value-of select="@id"/>
        </xsl:variable>
        <p>
            <xsl:for-each select="../../contrib-group/contrib/xref[@rid=$contriputeid]">
                <xsl:value-of select="../name/given-names"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="../name/surname"/>
                <xsl:if test="position() != last()">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:for-each>

        </p>
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
            <xsl:apply-templates select="email"/>
        </li>
    </xsl:template>

    <xsl:template match="author-notes/corresp/email">
        <a>
            <xsl:attribute name="href">
                <xsl:value-of select="concat('mailto:',.)"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </a>
        <xsl:variable name="contriputeid">
            <xsl:value-of select="../@id"/>
        </xsl:variable>
        <xsl:for-each select="../../../contrib-group/contrib/xref[@rid=$contriputeid]">
            <xsl:text> (</xsl:text>
            <xsl:value-of select="translate(../name/given-names, concat($smallcase, '. '), '')"/>
            <xsl:value-of select="translate(../name/surname, concat($smallcase, '. '), '')"/>
            <xsl:text>)</xsl:text>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="author-notes/fn[@fn-type='present-address']">
        <li>
            <span class="present-address-intials">
                <xsl:variable name="contriputeid">
                    <xsl:value-of select="@id"/>
                </xsl:variable>
                <!--<xsl:value-of select="$contriputeid"/> -->
                <xsl:for-each select="../../contrib-group/contrib/xref[@rid=$contriputeid]">
                    <xsl:text>--</xsl:text>
                    <xsl:value-of select="translate(../name/given-names, concat($smallcase, '. '), '')"/>
                    <xsl:text>-</xsl:text>
                    <xsl:value-of select="translate(../name/surname, concat($smallcase, '. '), '')"/>
                    <xsl:text>:</xsl:text>
                </xsl:for-each>
                <!--<xsl:value-of select="count(../../contrib-group/contrib/xref[@rid=$contriputeid])"/>-->
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
    <xsl:template match="fn-group[@content-type='ethics-information']">
        <div id="article-info-ethics">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="fn-group[@content-type='ethics-information']/fn">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="fn-group[@content-type='ethics-information']/title"/>

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

    <xsl:template match="sec/title">
        <xsl:element name="h{count(ancestor::sec) + 1}">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
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
            <a href="{@xlink:href}">
                <xsl:apply-templates/>
            </a>
        </xsl:if>
        <xsl:if test="@ext-link-type = 'doi'">
            <a href="/lookup/doi/{@xlink:href}">
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
            <xsl:when test="not(parent::boxed-text)">
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

    <xsl:template match="named-content[@content-type='author-callout-style1']">
        <span class="named-content author-callout-style1">
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

    <!-- individual fig in fig-group -->

    <xsl:template match="fig">
        <xsl:variable name="data-doi" select="child::object-id[@pub-id-type='doi']/text()"/>
        <div class="fig" data-doi="{$data-doi}">
            <xsl:apply-templates select="." mode="testing"/>
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
                            <a href="[graphic-{$graphics}-large]" target="_blank">Open in new tab</a>
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
                <span class="supplementary-material-label">
                    <xsl:value-of select="../label/text()"/>
                </span>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="fig//caption/title">
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
        <div class="elife-article-decision-letter" id='main-text'>
            <div class="article fulltext-view">
                <xsl:apply-templates mode="testing"/>
                <xsl:call-template name="appendices-main-text"/>
            </div>
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
                <div class="boxed-text">
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
        <xsl:variable name="graphics" select="child::graphic/@xlink:href"/>
        <div id="{$id}" class="fig-inline-img-set">
            <div class="elife-fig-image-caption-wrapper">
                <div class="fig-expansion">
                    <div class="fig-inline-img">
                        <a href="[graphic-{$graphics}-large]" class="figure-expand-popup" title="{$caption}">
                            <img data-img="[graphic-{$graphics}-small]" src="[graphic-{$graphics}-medium]" alt="{$caption}"/>
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
            <xsl:when test="@mimetype = 'application'">
                <!-- if mimetype is application -->
                <span class="inline-linked-media-wrapper">
                    <a href="[media-{substring-before(@xlink:href,'.')}-download]">
                        <i class="icon-download-alt"></i>
                        Download source data<span class="inline-linked-media-filename">
                            [<xsl:value-of
                                select="translate(translate(preceding-sibling::label, $uppercase, $smallcase), ' ', '-')"/>media-<xsl:value-of
                                select="count(preceding::media[@mimetype = 'application'])+1"/>.<xsl:value-of
                                select="substring-after(@xlink:href,'.')"/>]
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
    <!-- Acknowledgement -->

    <xsl:template match="ack">
        <div id="ack-1">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <!-- START Reference Handling -->

    <xsl:template match="ref-list">
        <div id="references">
            <div class="elife-reflinks-links">
                <xsl:apply-templates/>
            </div>
        </div>
    </xsl:template>

    <xsl:template match="ref">
        <article class="elife-reflinks-reflink" id="{@id}">
            <xsl:attribute name="data-original">
                <xsl:value-of select="translate(@id, $allcase, '')"/>
            </xsl:attribute>
            <xsl:variable name="slno" select="translate(@id, 'bib', '')"/>
            <div class="elife-reflink-indicators">
                <div class="elife-reflink-indicators-left">
                    <div class="elife-reflink-indicator-number">
                        <span data-counter="{$slno}">
                            <xsl:value-of select="(count(preceding::ref)+1)"/>
                        </span>
                    </div>

                </div>

            </div>
            <xsl:apply-templates/>
        </article>
    </xsl:template>

    <xsl:template match="ref/element-citation">
        <xsl:variable name="href">
            <xsl:choose>
                <xsl:when test="pub-id">
                    <xsl:value-of select="concat('http://dx.doi.org/', pub-id)"/>
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
                            <xsl:variable name="hrefvalue"
                                          select="concat('http://scholar.google.com/scholar?q=&quot;author:', $fullname, '&quot;')"/>
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

                <xsl:if test="$href != ''">
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
                            <a href="{$href}"><xsl:value-of select="$href"/></a>
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
            <xsl:when test="@mimetype != 'application'">
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

    <xsl:template match="sub-article//name/given-names | sub-article//name/surname">
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
        <xsl:apply-templates/>
        <xsl:if test="following-sibling::*">
            <xsl:text>, </xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template match="sub-article//role">
        <span class="nlm-role">
            <xsl:apply-templates/>
        </span>
        <xsl:text>, </xsl:text>
    </xsl:template>

    <xsl:template match="sub-article//institution | sub-article//country">
        <span class="nlm-{name()}">
            <xsl:apply-templates/>
        </span>
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
        [inline-graphic-<xsl:value-of select="@xlink:href"/>]
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
                <h2><xsl:value-of select="title"/></h2>
            </xsl:if>
            <xsl:apply-templates mode="testing"/>
        </div>
    </xsl:template>

    <!-- START - general format -->

    <!-- list elements start-->

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

    <xsl:template match="sub-article//title-group | sub-article/front-stub | fn-group[@content-type='competing-interest']/fn/p">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="caption | table-wrap/table | table-wrap-foot | fn | bold | italic | sub | sup | sec/title | ext-link | app/title | disp-formula" mode="testing">
        <xsl:apply-templates select="."/>
    </xsl:template>

    <!-- nodes to remove -->
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

</xsl:stylesheet>
