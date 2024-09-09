import { useContext } from 'react';
import { Route, Navigate } from 'react-router-dom';
import { UserContext } from '../UserContext';

function PrivateRoute({ children, ...props }) {
  const { user } = useContext(UserContext);

  return (
    <Route {...props} element={user ? children : <Navigate to="/login" replace />} />
  );
}

export default PrivateRoute;