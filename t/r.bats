@test mean123 {
   command -v r || skip "no 'r' command"
   output=$(echo -e '1\n2\n3' | r 'v=d %>% s(m=mean(V1)) %>% .$m %>% cat')
   [ $output == "2" ]
}
