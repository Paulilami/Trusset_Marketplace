// theme.ts
import { createTheme } from '@mui/material/styles';

// Custom colors for light and dark themes
const lightPalette = {
  primary: {
    main: '#1976d2',
  },
  secondary: {
    main: '#dc004e', 
  },
  background: {
    default: '#ffffff', 
    paper: '#f5f5f5', 
  },
  text: {
    primary: '#000000',
    secondary: '#666666', 
  },
};

const darkPalette = {
  primary: {
    main: '#EEEEEE', 
  },
  secondary: {
    main: '#686D76', 
  },
  background: {
    default: '#161616',
    paper: '#373A40', 
  },
  text: {
    primary: '#EEEEEE', 
    secondary: '#EEEEEE', 
  },
};

export const lightTheme = createTheme({
  palette: {
    mode: 'light',
    ...lightPalette,
  },
});

export const darkTheme = createTheme({
  palette: {
    mode: 'dark',
    ...darkPalette,
  },
});
