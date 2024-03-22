import { useState, useCallback } from 'react';
import { NextPage } from 'next';
import { Users, User } from '~/types/users/users';
import styles from '@/styles/Home.module.css';

const apiUrl = process.env.APP_API_URL || 'http://localhost:80';

const Users: NextPage = () => {
  const [users, setUsers] = useState<Users>();
  const getUsers = useCallback(async () => {
    try {
      const res = await fetch(`${apiUrl}/api/app/users`);

      if (!res.ok) {
        throw new Error(`HTTP error! Status: ${res.status}`);
      }

      const data: Users = await res.json();
      setUsers(data);
    } catch (error: any) {
      console.error('failed to fetch data:', error);
      throw new Error(error.message);
    }
  }, []);

  return (
    <div className={styles.container}>
      <button onClick={getUsers}>Fetch Users</button>
      {users && users.users.length > 0 && (
        <ul>
          {users.users.map((user: User) => (
            <li key={user.id}>
              {user.name} - {user.email}
            </li>
          ))}
        </ul>
      )}
    </div>
  );
};

export default Users;
