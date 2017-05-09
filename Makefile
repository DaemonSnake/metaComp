all:
	dub build;

clean:
	dub clean;

fclean:	clean
	rm -f metacomp;

re: fclean all
