all:
	stow --verbose --restow --target ~/.config .

delete:
	stow --verbose --delete --target ~/.config .


