"""
Genetic Algorithm implementation using NSGA-II
"""
from deap import base, creator, tools, algorithms
import numpy as np
from typing import List, Dict, Any, Tuple, Callable
import logging
import random


logger = logging.getLogger(__name__)




class GeneticOptimizer:
    """
    Multi-objective genetic algorithm optimizer using NSGA-II
    
    Optimizes multiple objectives simultaneously (e.g., maximize profit, minimize drawdown)
    """
    
    def __init__(
        self,
        parameters: List[Dict[str, Any]],
        objectives: List[str],
        evaluation_function: Callable,
        population_size: int = 100,
        generations: int = 50,
        crossover_prob: float = 0.7,
        mutation_prob: float = 0.2
    ):
        self.parameters = parameters
        self.objectives = objectives
        self.evaluation_function = evaluation_function
        self.population_size = population_size
        self.generations = generations
        self.crossover_prob = crossover_prob
        self.mutation_prob = mutation_prob
        
        self._setup_deap()
    
    def _setup_deap(self):
        """Setup DEAP framework"""
        # Create fitness and individual classes
        if hasattr(creator, "FitnessMulti"):
            del creator.FitnessMulti
        if hasattr(creator, "Individual"):
            del creator.Individual
        
        # Maximize all objectives (we'll negate minimization objectives)
        creator.create("FitnessMulti", base.Fitness, weights=tuple([1.0] * len(self.objectives)))
        creator.create("Individual", list, fitness=creator.FitnessMulti)
        
        self.toolbox = base.Toolbox()
        
        # Register attribute generators
        for i, param in enumerate(self.parameters):
            if param['type'] == 'int':
                self.toolbox.register(
                    f"attr_{i}",
                    random.randint,
                    param['min'],
                    param['max']
                )
            else:  # float
                self.toolbox.register(
                    f"attr_{i}",
                    random.uniform,
                    param['min'],
                    param['max']
                )
        
        # Register individual and population
        self.toolbox.register(
            "individual",
            tools.initCycle,
            creator.Individual,
            tuple([getattr(self.toolbox, f"attr_{i}") for i in range(len(self.parameters))]),
            n=1
        )
        
        self.toolbox.register("population", tools.initRepeat, list, self.toolbox.individual)
        
        # Register genetic operators
        self.toolbox.register("evaluate", self._evaluate)
        self.toolbox.register("mate", tools.cxTwoPoint)
        self.toolbox.register("mutate", self._mutate)
        self.toolbox.register("select", tools.selNSGA2)
    
    def _evaluate(self, individual: List[float]) -> Tuple[float, ...]:
        """
        Evaluate an individual
        
        Args:
            individual: List of parameter values
            
        Returns:
            Tuple of objective values
        """
        # Convert individual to parameter dictionary
        params = {
            self.parameters[i]['name']: individual[i]
            for i in range(len(self.parameters))
        }
        
        # Evaluate using provided function
        results = self.evaluation_function(params)
        
        # Extract objective values
        objective_values = []
        for obj in self.objectives:
            value = results.get(obj, 0)
            
            # Negate if we want to minimize this objective
            if obj in ['max_drawdown', 'max_drawdown_percent', 'volatility']:
                value = -value
            
            objective_values.append(value)
        
        return tuple(objective_values)
    
    def _mutate(self, individual: List[float]) -> Tuple[List[float]]:
        """
        Mutate an individual
        
        Args:
            individual: Individual to mutate
            
        Returns:
            Mutated individual
        """
        for i in range(len(individual)):
            if random.random() < 0.1:  # 10% chance per gene
                param = self.parameters[i]
                if param['type'] == 'int':
                    individual[i] = random.randint(param['min'], param['max'])
                else:
                    individual[i] = random.uniform(param['min'], param['max'])
        
        return (individual,)
    
    def optimize(self) -> Dict[str, Any]:
        """
        Run genetic algorithm optimization
        
        Returns:
            Dictionary with optimization results
        """
        logger.info(f"Starting genetic algorithm: {self.population_size} individuals, {self.generations} generations")
        
        # Create initial population
        population = self.toolbox.population(n=self.population_size)
        
        # Statistics
        stats = tools.Statistics(lambda ind: ind.fitness.values)
        stats.register("avg", np.mean, axis=0)
        stats.register("std", np.std, axis=0)
        stats.register("min", np.min, axis=0)
        stats.register("max", np.max, axis=0)
        
        # Hall of fame (best individuals)
        hof = tools.ParetoFront()
        
        # Run algorithm
        population, logbook = algorithms.eaMuPlusLambda(
            population,
            self.toolbox,
            mu=self.population_size,
            lambda_=self.population_size,
            cxpb=self.crossover_prob,
            mutpb=self.mutation_prob,
            ngen=self.generations,
            stats=stats,
            halloffame=hof,
            verbose=True
        )
        
        # Extract Pareto front
        pareto_front = []
        for rank, individual in enumerate(hof):
            params = {
                self.parameters[i]['name']: individual[i]
                for i in range(len(self.parameters))
            }
            
            objectives = {
                self.objectives[i]: individual.fitness.values[i]
                for i in range(len(self.objectives))
            }
            
            # Un-negate minimization objectives
            for obj in ['max_drawdown', 'max_drawdown_percent', 'volatility']:
                if obj in objectives:
                    objectives[obj] = -objectives[obj]
            
            pareto_front.append({
                'rank': rank + 1,
                'parameters': params,
                'objectives': objectives,
                'dominated_count': 0
            })
        
        logger.info(f"Optimization complete. Pareto front size: {len(pareto_front)}")
        
        return {
            'pareto_front': pareto_front,
            'best_solution': pareto_front[0] if pareto_front else None,
            'generations_completed': self.generations,
            'logbook': logbook
        }
