bool isLink(String input) {
  // Regular expression to match URLs
  // final RegExp urlRegExp = RegExp(
  //   r'^(https?|ftp):\/\/[^\s/$.?#].[^\s]*$',
  //   caseSensitive: false,
  //   multiLine: false,
  // );
  if (input == 'link') {
    return true;
  } else {
    return false;
  }
}

bool isLoading = false;

bool toggleButtons = false;

bool toggleSelectable = false;
