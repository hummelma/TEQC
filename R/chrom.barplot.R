chrom.barplot <-
function(reads, targets, plotchroms, col=c("darkgreen", "orange"), ylab, legendpos="topright", ...){
    
  # in case 'reads' is output of 'reads2pairs' and contains also 'singleReads'
  if(is.list(reads) & ("readpairs" %in% names(reads)))
    reads <- reads$readpairs  
  
  tab0 <- table(seqnames(reads))
  chrs <- names(tab0)
  
  if(!missing(plotchroms))
    if(!all(plotchroms %in% chrs))
      stop("'plotchroms' specify chromosome names that do not exist in the data")

  # if also targets are given ...
  if(!missing(targets)){
    # fraction of target - not in terms of numbers but in terms of target length
    targetlength <- width(targets)
    tabtar <- tapply(targetlength, seqnames(targets), sum)
    tabtar <- tabtar / sum(tabtar)
    
    # show fractions of reads instead of absolute numbers
    tab0 <- tab0 / sum(tab0)
    tmp <- setdiff(names(tabtar), chrs)
    tab0 <- c(tab0, rep(0, length(tmp)))
    names(tab0) <- c(chrs, tmp)
    chrs <- names(tab0)
  }

  if(missing(plotchroms)){
    # order chromosomes
    chr <- substr(chrs, 4, 4)
    g <- grep("chr\\d{2}", names(tab0), perl=TRUE)
    chr[g] <- substr(names(tab0)[g], 4, 5)
    chrn <- as.numeric(chr[!(chr %in% c("M", "U", "X", "Y"))])
    tab <- tab0[!(chr %in% c("M", "U", "X", "Y"))]
    tab <- tab[order(chrn)]
    tab <- c(tab, tab0[chr %in% c("M", "U", "X", "Y")])
  }
  # ... or select specified chromosomes
  else{
    tab <- tab0[plotchroms]
    tabtar <- tabtar[names(tabtar) %in% plotchroms]
  }

  # merge per-chromosome fractions of reads and targets (if latter is given)
  if(!missing(targets)){
    tab <- rbind(tab, 0)
    tab[2, names(tabtar)] <- tabtar
  }

  if(missing(ylab)){
    if(missing(targets))
      ylab <- "Number of reads"
    else
      ylab <- "Fraction"
  }
  if(missing(targets)){
    options(scipen=10)
    B <- barplot(tab, names.arg=rep("", length(tab)), col=col[1], ylab=ylab, ...)
    text(B, par("usr")[3], labels=names(tab), srt=45, adj=c(1,0.8), xpd=T, cex=1, font=2)
  }
  else{
    B <- barplot(tab, names.arg=rep("", length(tab)), beside=TRUE, col=col, ylab=ylab, ...)
    text(colMeans(B), par("usr")[3], labels=colnames(tab), srt=45, adj=c(1,0.8), xpd=T, cex=1, font=2)
    legend(legendpos, c("reads", "targets"), fill=col)
  }
}

