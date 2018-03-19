library(tuneR)
library(seewave)
library(data.table)

args = commandArgs(trailingOnly=TRUE)
recording_id <- args[1]
filename <- args[2];

folder <- "modules/traits-frequency/frequency/"

wave <- readWave(filename)
wave <- normalize(wave)

noise <- NULL;
tryCatch({
  url <- paste0("https://ams3.digitaloceanspaces.com/bioacoustica-analysis/noise/data/",
                recording_id,
                ".csv")
  noise <- fread(url)
}, error = function(err) {
  print("Noise data not found!");
})

png(filename=paste0("plots/",recording_id,".recording-spec.png"));
wave_spec <- meanspec(wave, norm=FALSE)
dev.off();

x <- wave_spec[,1]

if (is.null(noise)==FALSE) {
  for (i in 1:length(noise$xleft)) {
    if (i == 1) {
      w <- cutw(wave, from=noise$xleft[i], to=noise$xright[i], output="Wave")
    } else {
      w <- pastew(w, cutw(wave, from=noise$xleft[i], to=noise$xright[i], output="Wave"), output="Wave")
    }
  }
  png(filename=paste0("plots/",recording_id,".noise-spec.png"));
  noise_spec <- meanspec(w, norm=FALSE)
  dev.off();
  y <- wave_spec[,2] - noise_spec[,2]
} else {
  y <- wave_spec[,2]
}

#High-pass filter
limit <- 1
values <- which(x > limit)
x <- x[values]
y <- y[values]

y <- y / max(y) #normalise 

png(filename=paste0("plots/",recording_id,".png"));
plot(x,y^2, type="l")

y<- y^2
a <- y >= 0.5
r <- rle(a)
l <- c(0,cumsum(r$lengths))

regions <- r$lengths[which(r$values == TRUE)]
regions_l <- l[which(r$values == TRUE)]

longest <- which(regions == max(regions))

min <- x[regions_l[longest]]
max <- x[regions_l[longest] + regions[longest]]

abline(h=0.5, v=c(min,max))
dev.off();

data <- c(min, max, x[which(y==max(y))], mean(c(min,max)));

write.csv(data, paste0("data/",recording_id,".csv"))
