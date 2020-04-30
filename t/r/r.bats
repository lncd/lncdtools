@test mean123 {
   output=$(echo -e '1\n2\n3' | r 'v=d %>% s(m=mean(V1)) %>% .$m %>% cat')
   [ $output == "2" ]
}
