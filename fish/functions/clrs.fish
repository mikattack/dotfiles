
function clrs
  set DEFAULT 5
  set MIN 3
  set MAX 20
  set columns $DEFAULT

  # Validate input
  if count $argv > /dev/null
    if test $argv[1] -lt $MIN
      set columns 3
    else if test $argv[1] -gt $MAX
      set columns 20
    else
      set columns $argv[1]
    end
  end

  # Print color names in columns.  Note that the colors will be printed
  # "magazine-style", with sequential numbers reading downward, rather
  # than across.
  set range (echo "255 / $columns" | bc -l)
  set rounded (printf "%.0f" $range)

  # Print color names (tmux-style) in columns
  for row in (seq $rounded)
    set offset $row
    for column in (seq $columns)
      if test $offset -lt 256
        # printf "$offset \t"
        printf "\x1b[38;5;%dmcolour%-4s" $offset $offset
      end
      set offset (math "$offset + $rounded")
    end
    printf "\n"
  end
end

#!/bin/bash
#if [ -z $1 ]; then
#    BREAK=1
#else
#    BREAK=$1
#fi
#for i in {0..255} ; do
#    printf "\x1b[38;5;${i}mcolour${i} \t"
#    if [ $(( i % $BREAK )) -eq $(($BREAK-1)) ] ; then
#        printf "\n"
#    fi
#done

